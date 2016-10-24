import { Component, OnInit } from '@angular/core';
import { APIService } from '../services/api.service';

@Component({
    selector: 'private-app',
    providers: [APIService],
    template: `
    <nav-bar></nav-bar>
    <div class="ui grid container">
        <div class="twelve wide column centered">
        <router-outlet></router-outlet>
        </div>
    </div>
    `
})
export class PrivateComponent implements OnInit{
    error_message;

    constructor(private apiService: APIService) {}

    ngOnInit() {
        console.log(this.apiService);
        this.apiService.checkCredentials();
    }

    showErrorMessage(str): void{
        this.error_message = str;

        setTimeout(()=>{
            this.error_message = null;
        }, 3000);
    }
 }