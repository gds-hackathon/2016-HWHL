import { Component } from '@angular/core';
import { APIService } from './services/api.service';
import { Router } from '@angular/router';

@Component({
    selector: `login`,
    template: `
    <form #f="ngForm" (submit)="loginClicked()" class="ui large form segment" [ngClass]="{'error': error_message != null}">
    <div class="ui dividing header centered">GreenDotters Discount</div>
    <div class="field">
        <input name="phone" [(ngModel)]="phone" placeholder="手机号" required>
    </div>
    <div class="field">
        <input name="password" type="password" [(ngModel)]="password" placeholder="密码" required>
    </div>
    <div class = "ui error message">
        <p>{{error_message}}</p>
    </div>
    <div class="field centered">
        <button class="ui positive middle button" [disabled]="!f.valid">登录</button>
    </div>
    
    </form>
    `
})
export class LoginComponent{
    private phone: string;
    private password: string;
    private error_message: string;

    constructor(private apiService: APIService, private router: Router) {}

    loginClicked() {
        this.apiService.loginAccount(this.phone, this.password).then(response => {
            console.log(response);
            if (response.code != 200){
                this.error_message = response.message;
            }else{
                this.error_message = null;
            }
        });
    }

    ngOnInit() {
        if (this.apiService.access_token != null){
            this.router.navigate(['home']);
        }
    }
}