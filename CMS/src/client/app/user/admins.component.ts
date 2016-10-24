import { Component } from '@angular/core';
import { APIService } from '../services/api.service';
import { PrivateComponent } from '../foundation/private.component';

declare var jQuery: any;
declare var toastr: any;

@Component({
    selector: `admins`,
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
            <th>操作</th>
        </thead>
        <tr *ngFor="let s of shops">
            <td>{{ s.name }}</td>
            <td>{{ s.contact_name }}</td>
            <td>{{ u.phone }}</td>
            <td><button class="ui button positive" (click)="showDiscounts(u)">优惠活动</button></td>
        </tr>
    </table>
    `
})
export class AdminsComponent extends PrivateComponent {
    shops;

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
            console.log(data);
            this.shops = data.data.list;
        });
    }

    showDiscounts(u){
        this.selectedUser = u;
        jQuery('.ui.mini.modal').modal('show');
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

    levelName(level: number): string{
        if (level == null)
            level = 0;

        if (0 == level)
            return '普通';
        else if (level == 1)
            return '管理员';
        else
            return '超级管理员';
    }

    searchClicked(name, idcard_no, phone) {
        this.api.searchAccount(name.value, idcard_no.value, phone.value, 1).then(data => {
            if (data.code == 200){
                this.shops = data.data.list;

                toastr.success('查询成功', null, {timeout: 1000});
            }
        });
    }

    createClicked(name, idcard_no, phone){
        this.api.prepareAccount(name.value, idcard_no.value, phone.value, 1).then(data => {
            if (data.code == 200){
                name.value = null;
                idcard_no.value = null;
                phone.value = null;

                this.refreshList();
                toastr.success('添加成功', null, {timeout: 1000});
            }else {
                toastr.error(data.message, '添加失败', {timeout: 1000});
            }
        });
    }

    onChange(u: any, level: any){
        level = level.trim();

        var group_id = 0;
        if (level == '超级管理员'){
            group_id = 2;
        }else if (level == '管理员')
            group_id = 1;
        else
            group_id = 0;
        
        this.api.updateGroup(u.uid, group_id).then(data => {
            if (200 == data.code){
                toastr.success('修改成功', null, {timeout: 1000});
                u.group_id = group_id;
            }else{
                toastr.error(data.message, '修改失败', {timeout: 1000});
                u.group_id = u.group_id;
            }
        });

    }


}