import { Component } from '@angular/core';
import { NavBar } from './nav_bar.component';
import { APIService } from './services/api.service';
import { Http } from '@angular/http';
import { UserComponent } from './user/user.component';
import { NgModule } from "@angular/core";
import { NgSemanticModule } from "ng-semantic";
import { BrowserModule } from '@angular/platform-browser';

@NgModule({
    bootstrap:    [ AppComponent ],
    declarations: [ AppComponent, NavBar ],
    imports:      [ BrowserModule, NgSemanticModule ]
})

@Component({
    selector: 'credit-app',
    template: `
    <div class="ui centered grid">
    <div class="fourteen wide column">
        <nav-bar *ngIf="apiService.access_token != null"></nav-bar>
    </div>
    
     <div class="ui horizontal divider"></div>
     
        <div class="twelve wide column">
        <router-outlet></router-outlet>
        </div>
    </div>
    `
})
export class AppComponent {
    constructor(private apiService: APIService) { }
 }