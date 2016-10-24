import { Component } from '@angular/core';
import { PrivateComponent } from '../foundation/private.component';
import { APIService } from '../services/api.service';

declare var XLSX: any;
declare var toastr: any;
declare var jQuery: any;

@Component({
    selector: `blacklist`,
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
            <button class="ui orange button" (click)="addClicked(name_field,idcardno_field,phone_field)">添加</button>
            <div style="display:inline">
                <label for="file" class="ui icon button" [ngClass]="{'loading': isSubmitting}">
                    <i class="file icon"></i>
                    导入</label>
                <input type="file" id="file" style="display:none" (change)="importList($event)" *ngIf="!isSubmitting">
            </div>
            <button class="ui button" (click)="exportClicked()">导出</button>
            <div class="ui button" (click)="deleteMultiClicked()">批量删除</div>
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
            <th>标记次数</th>
            <th>最后标记时间</th>
        </thead>
        <tr *ngFor="let u of users">
            <td>{{ u.name }}</td>
            <td>{{ u.idcard_no }}</td>
            <td>{{ u.phone }}</td>
            <td>{{ u.reported_times }}</td>
            <td>{{ u.report_time }}</td>
        </tr>
    </table>
    <div *ngIf="users == null" class="ui floating message"><p>没有查询到数据</p></div>
    <div class="ui pagination menu" *ngIf="total_pages > 1">
        <a class="item" *ngFor="let p of paginationList()" (click)="showPage(p)" [ngClass]="{'active':p==page,'disabled':p=='...'}">{{p}}</a>
        
        <div *ngIf="total_pages > 12" class="ui action input">
            <input type="text" class="mini" style="width:40px" #goto_page>
            <button class="ui icon button" (click)="showPage(goto_page.value)"><i class="chevron right icon"></i></button> 
        </div>
    </div>
    <div class="ui mini modal" id="modal">
        <div class="header">批量删除</div>
        <div class="content">
            
            <p>请选择要删除的时间范围？</p>
            <div>
                <input type="datetime-local" id="start_date" #start_date />
                <input type="datetime-local" id="end_date" #end_date />
            </div>
            
        </div>
        <div class="actions">
            <div class="ui button" (click)="dismiss()">取消</div>
            <div class="ui negative right labeled icon button" (click)="confirmDelete(start_date, end_date)">
                删除
                <i class="delete icon"></i>
            </div>
    </div>
    `
})
export class BlacklistComponent extends PrivateComponent{
    phone;
    name;
    idcard_no;

    users;
    isSubmitting = false;
    page = 1;
    total = 0;
    total_pages = 0;

    constructor(private api: APIService){
        super(api);

        this.refreshBlacklist();
    }

    refreshBlacklist(){
        this.page = 1;
        this.api.getBlacklist(this.page).then(data => {
            console.log(data);
            this.users = data.data.list;
            this.total = data.data.total;
            this.total_pages = data.data.total_pages;
        });
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

    
    searchClicked() {
        this.page = 1;

        if (!this.name && !this.idcard_no && !this.phone){
            this.refreshBlacklist();
            return;
        }
            
        this.api.searchBlacklist(this.name, this.idcard_no, this.phone, this.page).then(data => {
            this.users = data.data.list;
            this.total = data.data.total;
            this.total_pages = data.data.total_pages;

            toastr.success('查询成功', null, {timeout: 1000});
        });
    }

    addClicked(name, idcard_no, phone){
        var nstr: string = name.value.trim();
        var istr: string = idcard_no.value.trim();
        var pstr: string = phone.value.trim();

        var error: string = null;
        if (istr.length != 18)
            error = "身份证号码长度不正确";
        else if (pstr.length != 11)
            error = "手机号码长度不正确";
        else if (nstr.length < 2)
            error = "请输入姓名";
        
        if (error){
            this.showErrorMessage(error);
            return;
        }

        this.api.importBlacklist([name.value], [idcard_no.value], [phone.value], [1]).then(data => {
            if (data.code == 200){
                name.value = null;
                idcard_no.value = null;
                phone.value = null;

                this.refreshBlacklist();

                toastr.success('添加成功', null, {timeout: 1000});
            }else {
                toastr.error(data.message, '添加失败', {timeout: 1000});
            }
        });
    }

    importClicked(){
        console.log(XLSX);
        XLSX.readFile('a.xls');
    }

    exportClicked(){
        var url = 'http://api.ttkkcx.com/index/index/export';
        window.open(url);
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
            var times = [];
            var sources = [];

            for (var b in blacklist){
                var r = blacklist[b];

                var values = [];

                for (var c in r){
                    values.push(r[c]);
                }

                names.push(values[0]);
                idcard_nos.push(values[1]);
                phones.push(values[2]);
                times.push(values[3]);
                sources.push(values[4]);
            }

            self.api.importBlacklist(names, idcard_nos, phones, times).then(data => {
                if (200 == data.code){
                    self.isSubmitting = false;
                    self.refreshBlacklist();
                }else{
                    self.showErrorMessage(data.message);
                }
            });
        }

        reader.readAsBinaryString(file);

        // var xmlsxPraser = null;//new SimpleExcel.Parser.CSV();
        // console.log(xmlsxPraser);
        // xmlsxPraser.loadFile(file, function(){
        //     var sheets = xmlsxPraser.getSheet();
        //     for (var s in sheets){
        //         console.log(sheets[s]);
        //     }
        //     console.log(xmlsxPraser.getSheet());
        // });        
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



        this.api.deleteBlacklist(0, sd.getTime() / 1000, ed.getTime() / 1000).then(response => {
            if (200 == response.code){
                this.dismiss();
                this.refreshBlacklist();

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