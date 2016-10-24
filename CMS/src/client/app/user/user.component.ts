import { Component } from '@angular/core';
import { APIService } from '../services/api.service';
import { PrivateComponent } from '../foundation/private.component';

declare var XLSX: any;
declare var toastr: any;
declare var jQuery: any;

@Component({
    selector: `user`,
    template: `
    <form class="ui large form segment" [ngClass]="{'error': error_message != null}">
    <div class="fields">
        <div class="three wide field">
            <div class="ui action input">
                <input type="text" placeholder="姓名" (input)="name = $event.target.value" #name_field>
                <div class="ui icon button" (click)="name_field.value = null;name = null"><i class="remove icon"></i></div>
            </div>
        </div>
        <div class="seven wide field">
            <div class="ui action input">
                <input type="text" placeholder="身份证号" (input)="idcard_no = $event.target.value" #idcardno_field>
                <div class="ui icon button" (click)="idcardno_field.value = null;idcard_no = null"><i class="remove icon"></i></div>
            </div>
        </div>
        <div class="six wide field">
            <div class="ui action input">
                <input type="text" placeholder="手机号" (input)="phone = $event.target.value" #phone_field>
                <div class="ui icon button" (click)="phone_field.value = null;phone = null"><i class="remove icon"></i></div>
            </div>
        </div>        
    </div>
    <div class="field">
        <button class="ui positive button" (click)="searchClicked()">查询</button>
        <button class="ui orange button" (click)="createClicked(name_field,idcardno_field,phone_field)">添加</button>
        <div style="display:inline">
            <label for="file" class="ui icon button" [ngClass]="{'loading': isSubmitting}">
                <i class="file icon"></i>
                导入</label>
            <input type="file" id="file" style="display:none" (change)="importList($event)" *ngIf="!isSubmitting">
        </div>
    </div>
    <div class = "ui error message">
        <p>{{error_message}}</p>
    </div>
    </form>
    <table class="ui celled table">
        <thead>
            <th>姓名</th>
            <th>身份证号</th>
            <th>手机号</th>
            <th>余额</th>
            <th>操作</th>
        </thead>
        <tr *ngFor="let u of users">
            <td>{{ u.name }}</td>
            <td>{{ u.idcard_no }}</td>
            <td>{{ u.phone }}</td>
            <td>{{ u.balance > 0 ? u.balance : 0 }}</td>
            <td>
                <div class="ui input" style="width:60px">
                    <input type="text" placeholder="余额" #times>
                </div>
                
                <sm-button class="icon green" icon="add" (click)="addClicked(u,times)">增加</sm-button>
                <sm-button class="icon red" icon="minus" (click)="minusClicked(u,times)">减少</sm-button>
            </td>
        </tr>
    </table>
    <div class="ui pagination menu" *ngIf="total_pages > 1">
        <a class="item" *ngFor="let p of paginationList()" (click)="showPage(p)" [ngClass]="{'active':p==page,'disabled':p=='...'}">{{p}}</a>
        
        <div *ngIf="total_pages > 12" class="ui action input">
            <input type="text" class="mini" style="width:40px" #goto_page>
            <button class="ui icon button" (click)="showPage(goto_page.value)"><i class="chevron right icon"></i></button> 
        </div>
    </div>
    
    `
})
export class UserComponent extends PrivateComponent {
    users;
    isSubmitting = false;
    page = 1;
    total = 0;
    total_pages = 0;

    name;
    idcard_no;
    phone;

    datestring = new Date().toDateString;

    constructor(private api: APIService){
        super(api);

        if (this.api.user_info.shop_id > 0)
            this.api.navigateTo("orders")
        else
            this.refreshList();

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
        this.api.getAccountList(this.page).then(data => {
            this.users = data.data.list;
            this.total = data.data.total;
            this.total_pages = data.data.total_pages;
        });
    }

    showPage(p){
        if (isNaN(parseInt(p)))
            return;

        this.page = parseInt(p);

        if (!this.name && !this.idcard_no && !this.phone){
            this.api.getAccountList(this.page).then(data => {
                this.users = data.data.list;
                this.total = data.data.total;
                this.total_pages = data.data.total_pages;
            });
        }else{
            this.api.searchAccount(this.name, this.idcard_no, this.phone, this.page).then(data => {
                this.users = data.data.list;
                this.total = data.data.total;
                this.total_pages = data.data.total_pages;
            });
        }
        
    }

    levelName(level: number): string{
        if (level == null)
            level = 0;

        if (level <= 0)
            return '普通';
        else
            return '不限查询次数';
    }

    searchClicked(name, idcard_no, phone) {
        this.page = 1;

        if (!this.name && !this.idcard_no && !this.phone){
            this.refreshList();
            return;
        }
        this.api.searchAccount(this.name, this.idcard_no, this.phone, 0).then(data => {
            this.users = data.data.list;
            this.total = data.data.total;
            this.total_pages = data.data.total_pages;

            toastr.success('查询成功', null, {timeout: 1000});
        });
    }

    createClicked(name, idcard_no, phone){
        this.api.prepareAccount(name.value, idcard_no.value, phone.value).then(data => {
            if (data.code == 200){
                toastr.success(data.message, '添加成功', {timeout: 1000});

                name.value = null;
                idcard_no.value = null;
                phone.value = null;

                this.refreshList();
            }else {
                toastr.error(data.message, '添加失败', {timeout: 1000});
                this.showErrorMessage(data.message);
            }
        });
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

    addClicked(u: any, field: any){
        var times = parseInt(field.value);
        if (isNaN(times) || times < 1)
            return;

        var balance = parseInt(u.balance);
        if (isNaN(balance))
            balance = 0;

        balance += times;
        u.balance = balance;

        field.value = null;

        this.api.updateBalance(u.uid, balance);

        toastr.success('增加成功', null, {timeout: 2000});
    }

    minusClicked(u: any, field: any){
        var times = parseInt(field.value);
        if (isNaN(times) || times < 1)
            return;

        var balance = u.balance > 0 ? u.balance : 0;
        balance = balance - times;
        u.balance = balance;

        field.value = null;

        this.api.updateBalance(u.uid, balance);

        toastr.success('减少成功', null, {timeout: 2000});
    }

    importList($event){
        var file = $event.target.files[0];

        this.isSubmitting = true;
        

        var reader = new FileReader();

        var self = this;
        reader.onload = function(e){
            var arrayBuffer = reader.result;
            var workbook = XLSX.read(arrayBuffer, {type: 'binary'});

            var first_sheet_name = workbook.SheetNames[0];
            var worksheet = workbook.Sheets[first_sheet_name];

            var blacklist = XLSX.utils.sheet_to_json(worksheet);

            var names = [];
            var idcard_nos = [];
            var phones = [];

            for (var b in blacklist){
                var r = blacklist[b];

                var values = [];

                for (var c in r){
                    values.push(r[c]);
                }

                names.push(values[0]);
                idcard_nos.push(values[1] == null ? '' : values[1]);
                phones.push(values[2]);
            }

            self.api.importUsers(names, idcard_nos, phones).then(data => {
                if (200 == data.code){
                    self.isSubmitting = false;
                    self.refreshList();
                }else{
                    self.showErrorMessage(data.message);
                }
            });
        }

        reader.readAsBinaryString(file);      
    }

    deleteMultiClicked(): void{
        var tzoffset = (new Date()).getTimezoneOffset() * 60000;
        var now = new Date(Date.now() - tzoffset).toISOString().slice(0,-8);
        jQuery('#start_date').attr('value', now);
        jQuery('#end_date').attr('value', now);

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

    dismiss(){
        
        jQuery('.ui.mini.modal').modal('hide');
    }
}