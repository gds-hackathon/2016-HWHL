import { Component } from '@angular/core';
import { APIService } from '../services/api.service';
import { PrivateComponent } from '../foundation/private.component';

declare var jQuery: any;
declare var toastr: any;

@Component({
    selector: `discounts`,
    template: `
    <form class="ui large form segment" [ngClass]="{'error': error_message != null}">
    <div class="fields">
        <div class="seven wide field">
            <div class="ui action input">
            <select class="ui fluid dropdown" (change)="typeChanged(discount_type.value)" required #discount_type>
                <option value=""></option>
                <option value="0">折扣</option>
                <option value="1">满减</option>
                <option value="2">每满减</option>
            </select>
            </div>
        </div>
        <div class="four wide field">
            <div class="ui action input">
                <input type="text" placeholder="{{placeholderF1}}" #factor1>
                <div class="ui icon button" (click)="factor1.value = null"><i class="remove icon"></i></div>
            </div>
        </div>
        <div class="five wide field" [ngClass]="{'disabled': discountType == 0}">
            <div class="ui action input hide">
                <input type="text" placeholder="减XX" #factor2>
                <div class="ui icon button" (click)="factor2.value = null"><i class="remove icon"></i></div>
            </div>
        </div>        
    </div>
    <div class="field">
        <button class="ui orange button" (click)="createClicked(discount_type,factor1,factor2)">添加</button>
    </div>
    <div class = "ui error message">
        <p>{{error_message}}</p>
    </div>
    </form>
    <table class="ui celled table">
        <thead>
            <th>优惠</th>
            <th>创建时间</th>
            <th>操作</th>
        </thead>
        <tr *ngFor="let d of discounts">
            <td>{{ parseDiscount(d) }}</td>
            <td>{{ d.create_time }}</td>
            <td><button class="ui button" (click)="deleteDiscount(d)">删除</button></td>
        </tr>
    </table>
    `
})
export class DiscountsComponent extends PrivateComponent {
    discounts = null;
    page = 1;
    selectedUser;

    placeholderF1 = "折扣";
    placeHolderF2 = "减"
    discountType = 0;

    constructor(private api: APIService){
        super(api);

        this.refreshList();
    }

    factorChanged(f2){
        console.log(f2);
    }

    refreshList(): void{
        this.api.getDiscountList(1).then(data => {
            this.discounts = data.data;
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

    parseDiscount(info): string{
        var discount_type = parseInt(info.discount_type);
        if (isNaN(discount_type))
            discount_type = 0;

        var factor1 = parseFloat(info.factor1);
        var factor2 = parseFloat(info.factor2);

        if (0 == discount_type)
            return String(factor1 * 10) + "折";
        else if (1==discount_type)
            return "满" + String(factor1) + "减" + String(factor2);
        else
            return "每满" + String(factor1) + "减" + String(factor2);
    }

    typeChanged(item){
        var dt = parseInt(item);
        if (isNaN(dt))
            dt = 0;
        this.discountType = dt;

        if (0 == this.discountType) {
            this.placeholderF1 = "折扣";
        }else if (1 == this.discountType) {
            this.placeholderF1 = "满XX";
        }else if (2 == this.discountType){
            this.placeholderF1 = "每满XX";
        }

        console.log(this.discountType);
    }

    deleteDiscount(info){
        this.api.removeDiscount(info.discount_id).then(response => {
            if (200 == response.code){
                this.refreshList();

                toastr.success('删除成功', null, {timeout: 1000});
            }else{
                this.refreshList();

                toastr.error(response.message, '删除失败', {timeout: 1000});
            }
        });
    }

    confirmDelete(){
        this.api.deleteAccount(this.selectedUser.uid).then(response => {
            if (200 == response.code){
                this.dismiss();
                this.selectedUser = null;
                this.api.getDiscountList(1).then(data => {
                    this.discounts = data.list;
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





    createClicked(discount_type, factor1, factor2){
        var vdt = parseInt(discount_type.value);

        
        if (isNaN(vdt))
            vdt = 0;
        this.api.addDiscount(this.api.user_info.shop_id, discount_type.value, factor1.value, vdt == 0 ? 0 : factor2.value).then(data => {
            if (data.code == 200){
                this.refreshList();
                toastr.success('添加成功', null, {timeout: 1000});
            }else {
                toastr.error(data.message, '添加失败', {timeout: 1000});
            }
        });
    }

    


}