import { Component } from '@angular/core';
import { APIService } from '../services/api.service';
import { PrivateComponent } from '../foundation/private.component';

declare var toastr: any;

@Component({
    selector: `statics`,
    template: `
    <table class="ui celled table">
        <thead>
            <th>每月支付次数</th>
            <th>餐厅平均支付次数</th>
            <th>餐厅平均收入</th>
            <th>员工平均支出</th>
        </thead>
        <tr *ngIf="summaryInfo != null">
            <td>{{ summaryInfo.ppm }}</td>
            <td>{{ summaryInfo.ppr }}</td>
            <td>{{ summaryInfo.apr }}</td>
            <td>{{ summaryInfo.apa }}</td>
        </tr>
    </table>

    <table *ngIf="summaryInfo != null" class="ui celled table">
        <thead>
            <th>排名</th>
            <th>餐厅</th>
        </thead>
        <tr *ngFor="let u of shops">
            <td>{{ u.rank }}</td>
            <td>{{ u.name }}</td>
        </tr>
    </table>
    `
})
export class StaticsComponent extends PrivateComponent {
    users;
    phone;
    name;
    summaryInfo;
    shops;

    selectedIndex = 0;

    is_recent = 0;

    constructor(private api: APIService){
        super(api);

        // this.api.getLocations(1,this.phone,this.name).then(data => {
        //     console.log(data);
        //     this.users = data.data;
        // });

        if (!(this.api.user_info.group_id != null && this.api.user_info.group_id > 1)){
            this.api.navigateTo('home');
        }

        this.getStaticsInfo();
    }

    getStaticsInfo(){
        this.api.getStaticsInfo().then(response => {
            this.summaryInfo = response.data;
            this.shops = this.summaryInfo.shops;

            console.log(this.summaryInfo);
        });
    }

    sectionClicked(section: number): void{
        this.is_recent = section;

        this.users = null;
    }

    openMap(u){
        var url = this.mapURL(u);
        window.open(url);
    }

    mapThumbURL(u): string{
        var latitude = u.latitude != null ? u.latitude : 0;
        var longitude = u.longitude != null ? u.longitude : 0;
        return "http://restapi.amap.com/v3/staticmap?location=" + longitude.toString() + "," + latitude.toString() + "&zoom=12&size=440*280&markers=mid,,A:" + longitude.toString() + "," + latitude.toString() + "&key=baf42397f00a52490363153067ea0bce";
    }

    mapURL(u): string{
        var latitude = u.latitude != null ? u.latitude : 0;
        var longitude = u.longitude != null ? u.longitude : 0;
        var name= u.name;
        return "http://m.amap.com/navi/?dest=" + longitude.toString() + "," + latitude.toString() + "&destName=" + u.name + '%20' + (u.modify_time != null ? u.modify_time : u.create_time) + "&hideRouteIcon=1&key=baf42397f00a52490363153067ea0bce";
    }

    searchClicked(name, phone) {
        this.api.getLocations(1, phone.value, name.value, this.is_recent).then(data => {
            if (data.code == 200){
                if (data.data != null && Array.isArray(data.data))
                    this.users = data.data;
                else
                    this.users = null;

                toastr.success('查询成功', null, {timeout: 1000});
            }
        });
    }

}