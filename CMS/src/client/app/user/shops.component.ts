import { Component } from '@angular/core';
import { APIService } from '../services/api.service';
import { PrivateComponent } from '../foundation/private.component';

declare var jQuery: any;
declare var toastr: any;

@Component({
    selector: `shops`,
    template: `
    <form class="ui large form segment" [ngClass]="{'error': error_message != null}">
    <div class="fields">
        <div class="seven wide field">
            <div class="ui action input">
                <input type="text" placeholder="商户名" #name>
                <div class="ui icon button" (click)="name.value = null"><i class="remove icon"></i></div>
            </div>
        </div>
        <div class="four wide field">
            <div class="ui action input">
                <input type="text" placeholder="联系人" #contact_name>
                <div class="ui icon button" (click)="idcard_no.value = null"><i class="remove icon"></i></div>
            </div>
        </div>
        <div class="five wide field">
            <div class="ui action input">
                <input type="text" placeholder="联系方式" #phone>
                <div class="ui icon button" (click)="phone.value = null"><i class="remove icon"></i></div>
            </div>
        </div>        
    </div>
    <div class="field">
        <button class="ui positive button" (click)="searchClicked(name,contact_name,phone)">查询</button>
        <button class="ui orange button" (click)="createClicked(name,contact_name,phone)">添加</button>
    </div>
    <div class = "ui error message">
        <p>{{error_message}}</p>
    </div>
    </form>
    <table class="ui celled table">
        <thead>
            <th>商户名</th>
            <th>联系人</th>
            <th>联系方式</th>
            <th>优惠活动</th>
        </thead>
        <tr *ngFor="let s of shops">
            <td>{{ s.name }}</td>
            <td>{{ s.owner_name }}</td>
            <td>{{ s.phone }}</td>
            <td>{{ showDiscounts(s.discounts) }}</td>
        </tr>
    </table>
    `
})
export class ShopsComponent extends PrivateComponent {
    shops;
    page = 1;
    selectedUser;

    constructor(private api: APIService){
        super(api);

        this.refreshList();

        if (!(this.api.user_info.group_id != null && this.api.user_info.group_id > 1)){
            this.api.navigateTo('home');
        }
    }

    refreshList(): void{
        this.api.getShopList(1).then(data => {
            this.shops = data.data.list;
        });
    }

    showDiscounts(discounts): string{
        if (discounts != null) {
            var result = "";

            for (var d in discounts) {
                console.log(discounts);
                var info = discounts[d];

                var discount_type = parseInt(info.discount_type);
                var factor1 = parseFloat(info.factor1);
                var factor2 = parseFloat(info.factor2);

                if (isNaN(discount_type))
                    discount_type = 0;

                if (0 == discount_type)
                    result += String(factor1 * 10) + "折;";
                else if (1==discount_type)
                    result += "满" + String(factor1) + "减" + String(factor2) +";";
                else
                    result += "每满" + String(factor1) + "减" + String(factor2) +";";
            }

            return result;
        }

        return null;
    }

    confirmDelete(){
        this.api.deleteAccount(this.selectedUser.uid).then(response => {
            if (200 == response.code){
                this.dismiss();
                this.selectedUser = null;
                this.api.getAccountList(1,1).then(data => {
                    this.shops = data.data.list;
                });

                toastr.success('删除成功', null, {timeout: 1000});
            }else{
                this.dismiss();

                toastr.error(response.message, '删除失败', {timeout: 1000});
            }
        });
    }

    dismiss(){
        jQuery('.ui.mini.modal').modal('hide');
    }



    searchClicked(name, contact_name, phone) {
        this.page = 1;
        this.api.getShopList(this.page, name.value, contact_name.value, phone.value).then(data => {
            if (data.code == 200){
                this.shops = data.data.list;

                toastr.success('查询成功', null, {timeout: 1000});
            }
        });
    }

    createClicked(name, contact_name, phone){
        this.api.prepareShopAccount(name.value, contact_name.value, phone.value).then(data => {
            if (data.code == 200){
                name.value = null;
                contact_name.value = null;
                phone.value = null;

                this.refreshList();
                toastr.success('添加成功', null, {timeout: 1000});
            }else {
                toastr.error(data.message, '添加失败', {timeout: 1000});
            }
        });
    }

    


}