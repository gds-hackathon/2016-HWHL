import { Component } from '@angular/core';
import { PublicComponent } from '../foundation/public.component';
import { APIService } from '../services/api.service';

declare var jQuery: any;

@Component({
    selector: 'score',
    template: `
    <form class="ui form" (ngSubmit)="onSubmit(f)" #f="ngForm">
    <div class="four fields">
        <div class="field">
            <input type="text" placeholder="姓名" (input)="record.name = $event.target.value" required>
        </div>
        <div class="field">
            <input type="text" placeholder="身份证号" (input)="record.idcard_no = $event.target.value" required>
        </div>
        <div class="field">
            <input type="number" placeholder="手机号" (input)="record.phone = $event.target.value" required>
        </div>
        <div class="field">
            <input type="text" placeholder="居住地" (input)="record.area = $event.target.value" required>
        </div>        
    </div>
    <div *ngFor="let l of allOptions" class="four fields">
        <div *ngFor="let option of l;let i=index" class="field">
            <label>{{option.name}}</label>
            <select *ngIf="option.items != null" class="ui fluid dropdown" (change)="option.value = $event.target.value" required>
                <option value=""></option>
                <option *ngFor="let item of option.items;let j = index" value="{{j + 1}}">{{item}}</option>
            </select>
            <input *ngIf="option.items==null" type="number"  (input)="option.value = $event.target.value" required>
        </div>
    </div> 
    <div class="field">
        <div class="ui checkbox">
            <input type="checkbox" name="example" required>
            <label>本人保证以上所填信息真实有效，如有虚假或欺诈自愿承担民事及刑事责任</label>
        </div>
    </div>
    <button class="ui button" type="submit">提交</button>
    </form>
    `
})
export class ScoreComponent extends PublicComponent{
    allOptions: any = [
        [{name: '有无重大疾病', key: 'has_disease', items: ['无', '有']},
        {name: '婚姻状况', key: 'marriage_status', items: ['未婚', '已婚', '离婚']},
        {name: '有无子女', key: 'has_kids', items: ['无', '有']},
        {name: '是否给父母赡养费', key: 'give_alimony', items: ['否', '是']}],
        [{name: '学历', key: 'education', items: ['高中以下', '高中', '专科', '本科', '本科以上']},
        {name: '驾照', key: 'drive_license', items: ['无', '有']},
        {name: '工作属性', key: 'job', items: ['无业', '事业单位', '外资企业', '私营企业']},
        {name: '月薪', key: 'salary'}],
        [{name: '芝麻信用分', key: 'alipay_score'},
        {name: '是否有房', key: 'house', items: ['无', '有']},
        {name: '是否有车', key: 'car', items: ['无', '有']},
        {name: '个人爱好', key: 'interest', items: ['无', '字画戏曲', '旅游摄影', '棋牌游戏']}],
        [{name: '居住证积分', key: 'resident_score'},
        {name: '家族担保人', key: 'has_guarantor', items: ['无', '有']},
    ]];

    record = {};

    constructor(private api: APIService) { 
        super(api);
    }

    onSubmit(f){
        var parameters = {};
        for (var i in this.allOptions){
            var l = this.allOptions[i];
            for (var j in l){
                var option = l[j];

                if (option.value != null)
                    parameters[option.key] = option.value;
            }
        }

        for (var key in this.record){
            if (this.record[key] != null)
                parameters[key] = this.record[key];
        }

        this.api.submitProfile(parameters).then(data => {
            if (200 == data.code){
                var score: number = parseInt(data.data.score);
                if (isNaN(score))
                    score = 0;
                alert('您的信用评估得分为：' + score.toString());
                window.location.reload();
            }
        });
        
    }

}