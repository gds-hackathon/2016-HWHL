import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { APP_BASE_HREF } from '@angular/common';
import { RouterModule } from '@angular/router';
import { HttpModule } from '@angular/http';
import { AppComponent } from './app.component';
import { routes } from './app.routes';
import { NgSemanticModule } from 'ng-semantic';

import { AboutModule } from './about/about.module';

import { SharedModule } from './shared/shared.module';

import { NavBar } from './nav_bar.component';
import { APIService } from './services/api.service';
import { UserComponent } from './user/user.component';
import { LoginComponent } from './login.component';
import { AdminsComponent } from './user/admins.component';
import { ShopsComponent } from './user/shops.component';
import { OrdersComponent } from './user/orders.component';
import { DiscountsComponent } from './user/discounts.component';
import { StaticsComponent } from './user/statics.component';

@NgModule({
  imports: [BrowserModule, HttpModule, NgSemanticModule, RouterModule.forRoot(routes), AboutModule, SharedModule.forRoot()],
  declarations: [AppComponent, NavBar, UserComponent, LoginComponent, AdminsComponent, ShopsComponent, OrdersComponent, DiscountsComponent, StaticsComponent],
  providers: [{
    provide: APP_BASE_HREF,
    useValue: '<%= APP_BASE %>'
  }, APIService],
  bootstrap: [AppComponent]

})

export class AppModule { }
