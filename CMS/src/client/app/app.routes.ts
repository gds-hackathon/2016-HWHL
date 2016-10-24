import { Routes } from '@angular/router';

import { LoginComponent }      from './login.component';
import { UserComponent }    from './user/user.component';
import { AdminsComponent } from './user/admins.component';
import { ScoresComponent } from './user/scores.component';
import { ShopsComponent } from './user/shops.component';
import { OrdersComponent } from './user/orders.component';
import { DiscountsComponent } from './user/discounts.component';
import { StaticsComponent } from './user/statics.component';


export const routes: Routes = [
    { path: '', redirectTo: 'home', pathMatch: 'full' },
    { path: 'home', component: UserComponent },
    { path: 'user', component: UserComponent },
    { path: 'login', component: LoginComponent },
    { path: 'score', component: ScoreComponent },
    { path: 'admins', component: AdminsComponent },
    { path: 'shops', component: ShopsComponent },
    { path: 'orders', component: OrdersComponent },
    { path: 'discounts', component: DiscountsComponent },
    { path: 'statics', component: StaticsComponent }

];
