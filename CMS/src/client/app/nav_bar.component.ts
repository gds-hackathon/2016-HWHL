import { Component, OnInit, ElementRef } from '@angular/core';
import { APIService } from './services/api.service';
import { Router } from '@angular/router';

declare var jQuery: any;

@Component({
    selector: 'nav-bar',
    template: `
    <div class="ui menu">
        <a  class="header item">
          GreenDotteers
        </a>
        <a *ngIf="apiService.user_info.group_id > 1" class="item" [routerLink]="['user']" routerLinkActive="active">员工管理</a>
        <a *ngIf="apiService.user_info.group_id > 1" class="item" [routerLink]="['shops']" routerLinkActive="active">商户管理</a>
        <a *ngIf="apiService.user_info.group_id == 1" class="item" [routerLink]="['discounts']" routerLinkActive="active">促销管理</a>
        <a *ngIf="apiService.user_info.group_id > 0" class="item" [routerLink]="['orders']" routerLinkActive="active">订单数据</a>
        <a *ngIf="apiService.user_info.group_id > 1" class="item" [routerLink]="['statics']" routerLinkActive="active">统计数据</a>
        <div class="right menu" *ngIf="apiService.access_token != null">
            <div class="header item borderless">
                    Welcome! {{apiService.user_info.name}}
            </div>
            <a class="item" (click)="logout()" >注销</a>
        </div>
    </div>
    `
})
export class NavBar implements OnInit { 
    options = ["添加业务员", "添加查询次数", "管理用户组"]



    constructor(private elementRef: ElementRef, private apiService: APIService, private router: Router) {

    }



    ngOnInit() {
        jQuery(this.elementRef.nativeElement).find('.ui.dropdown').dropdown();
    }

    optionClicked(t: String): void {
        console.log(t + "Clicked");
    }

    logout(){
        this.apiService.logout();
    }

    // isActive(instruction: any[]): boolean{
    //     return this.router.isActive()
    // }
}