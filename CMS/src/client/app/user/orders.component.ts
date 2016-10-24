import { Component } from '@angular/core';
import { APIService } from '../services/api.service';
import { PrivateComponent } from '../foundation/private.component';

declare var XLSX: any;
declare var toastr: any;
declare var jQuery: any;

@Component({
    selector: `orders`,
    template: `
    <table class="ui celled table">
        <thead>
            <th>员工</th>
            <th>商家名称</th>
            <th>消费金额</th>
            <th>支付方式</th>
            <th>消费日期</th>
        </thead>
        <tr *ngFor="let o of orders">
            <td>{{ o.customer_name }}</td>
            <td>{{ o.shop_name }}</td>
            <td>{{ o.price }}</td>
            <td>{{ parsePayType(o.source) }}</td>
            <td>{{ o.create_time }}</td>
        </tr>
    </table>
    <div class="ui pagination menu" *ngIf="total_pages > 1">
        <a class="item" *ngFor="let p of paginationList()" (click)="showPage(p)" [ngClass]="{'active':p==page,'disabled':p=='...'}">{{p}}</a>
        
        <div *ngIf="total_pages > 12" class="ui action input">
            <input type="text" class="mini" style="width:40px" #goto_page>
            <button class="ui icon button" (click)="showPage(goto_page.value)"><i class="chevron right icon"></i></button> 
        </div>
    </div>
    <div class="ui mini modal" id="modal">
        <div class="header">详细资料</div>
        <div class="content">
            
            <form class="ui form">
                <div *ngFor="let item of currentDetail" class="four fields">
                    <div *ngFor="let sitem of item" class="field">
                        <label>{{sitem.name}}</label>
                        {{sitem.value}}
                    </div>  
                </div>
            </form>
            
        </div>
        <div class="actions">
            <div class="ui button" (click)="dismiss()">取消</div>
        </div>
    </div>
    `
})
export class OrdersComponent extends PrivateComponent {
    orders;
    page = 1;
    total = 0;
    total_pages = 0;

    currentDetail;

    datestring = new Date().toDateString;

    

    constructor(private api: APIService){
        super(api);
        this.refreshList();


    }

    parsePayType(pay_type): string{
        if (pay_type == 'alipay')
            return '支付宝';
        else if (pay_type == 'wxpay')
            return '微信';
        else
            return '余额';
    }

    removeClick(){
        console.log('asdfsaf');
    }

    paginationList(){
        if (this.total_pages <= 12){
            var p = [];
            for (var i = 1; i <= this.total_pages;i++){
                p.push(i.toString());
            }

            return p;
        }else{
            p = ['1','2','3'];
            p.push('...');
            p.push((this.total_pages - 2).toString());
            p.push((this.total_pages - 1).toString());
            p.push((this.total_pages).toString());

            return p;
        }
    }



    refreshList(){
        this.page = 1;
        var shop_id = parseInt(this.api.user_info.shop_id);
        if (isNaN(shop_id))
            shop_id = 0;
        
        this.api.getOrderList(this.page, 0, shop_id).then(data => {
            this.orders = data.data.list;
            this.total = data.data.total;
            this.total_pages = data.data.total_pages;
        });
    }

    showPage(p){
        if (isNaN(parseInt(p)))
            return;

        this.page = parseInt(p);
        var shop_id = parseInt(this.api.user_info.shop_id);

        this.api.getOrderList(this.page, 0, shop_id).then(data => {
            this.orders = data.data.list;
            this.total = data.data.total;
            this.total_pages = data.data.total_pages;
        });
        
    }

    levelName(level: number): string{
        if (level == null)
            level = 0;

        if (level <= 0)
            return '普通';
        else
            return '不限查询次数';
    }

   

    onChange(u: any, level: any){
        level = level.trim();

        var unlimited_search = 0;
        if (level == '普通'){
            unlimited_search = 0;
        }else
            unlimited_search = 1;

        
        this.api.updateUnlimitedSearch(u.uid, unlimited_search).then(data => {
            if (200 == data.code){
                u.unlimited_search = unlimited_search;

                toastr.success('修改成功', null, {timeout: 1000});
            }else{
                u.unlimited_search = u.unlimited_search;
                toastr.error(data.message, '修改失败', {timeout: 1000});
            }
        });

    }

    showDetail(u): void{
        this.currentDetail = this.getDetailItems(u);

        jQuery('.ui.mini.modal').modal('show');
    }



    confirmDelete(start_date, end_date){
        var tzoffset = (new Date()).getTimezoneOffset() * 60000;
        var sd = start_date.value;
        var ed = end_date.value;

        sd = new Date(new Date(sd).getTime() + tzoffset);
        ed = new Date(new Date(ed).getTime() + tzoffset);



        this.api.deleteAccount(0, sd.getTime() / 1000, ed.getTime() / 1000).then(response => {
            if (200 == response.code){
                this.dismiss();
                this.refreshList();

                var deleted = 0;
                if (response.data != null)
                    deleted = parseInt(response.data['deleted']);
                if (isNaN(deleted))
                    deleted = 0;

                toastr.success('删除成功', "总共删除" + deleted.toString() + "条", {timeout: 1000});
            }else{
                this.dismiss();

                toastr.error(response.message, '删除失败', {timeout: 1000});
            }
        });
    }

    

    getDetailItems(user): any{
        var allOptions: any = [
        {name: '姓名', key: 'name'},
        {name: '身份证号', key: 'idcard_no'},
        {name: '手机号', key: 'phone'},
        {name: '居住地', key: 'area'},
        {name: '有无重大疾病', key: 'has_disease', items: ['无', '有']},
        {name: '婚姻状况', key: 'marriage_status', items: ['未婚', '已婚', '离婚']},
        {name: '有无子女', key: 'has_kids', items: ['无', '有']},
        {name: '是否给父母赡养费', key: 'give_alimony', items: ['否', '是']},
        {name: '学历', key: 'education', items: ['高中以下', '高中', '专科', '本科', '本科以上']},
        {name: '驾照', key: 'drive_license', items: ['无', '有']},
        {name: '工作属性', key: 'job', items: ['无业', '事业单位', '外资企业', '私营企业']},
        {name: '月薪', key: 'salary'},
        {name: '芝麻信用分', key: 'alipay_score'},
        {name: '是否有房', key: 'house', items: ['无', '有']},
        {name: '是否有车', key: 'car', items: ['无', '有']},
        {name: '个人爱好', key: 'interest', items: ['无', '字画戏曲', '旅游摄影', '棋牌游戏']},
        {name: '居住证积分', key: 'resident_score'},
        {name: '家族担保人', key: 'has_guarantor', items: ['无', '有']},
        ];
        var items = [];
        console.log(user);
        for (var option_index in allOptions){
            var item = {};

            var option = allOptions[option_index];
            
            var key = option['key'];
            var name = option['name'];
            var values = option['items'];

            item['name'] = name;


            var i = user[key];

            if (values){
                i = parseInt(i);
                if (isNaN(i) || i < 1)
                    continue;
                else{
                    item['value'] = values[i-1];
                    items.push(item);
                }
            }else{
                if (i){
                    item['value'] = i;
                    items.push(item);
                }
            }
        }

        var groupedItems = items.slice(0,(items.length+4-1)/4|0).
           map(function(c,i) { return items.slice(4*i,4*i+4); });

        console.log(groupedItems);
        return groupedItems;
    }

    dismiss(){
        
        jQuery('.ui.mini.modal').modal('hide');
    }
}