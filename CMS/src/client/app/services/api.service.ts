import { Injectable } from '@angular/core';
import { Subject, BehaviorSubject, Observable } from 'rxjs';
import { Http, Headers, RequestOptions } from '@angular/http';
import { Router } from '@angular/router';
import 'rxjs/add/operator/toPromise';

var CryptoJS = require('crypto-js/crypto-js.js');



@Injectable()
export class APIService {
    private static BASE_URL: string = "http://greendot.5stan.com/admin/";//"http://localhost:8888/greendot/admin/";//http://121.40.136.72/api/";
    private static APP_ID: string = "greendot_discounts";
    private static APP_SECRET: string = "ac15bc3fb9e85961b3f0e61b4a96277dc0c0de87";
    private static APP_VERSION = '1.0';

    private isDebug = false;

    access_token: string;
    user_info: any;

    private device_id: string;

    constructor(private http: Http, private router: Router) {
        if (this.isDebug){
            APIService.BASE_URL = "http://localhost:8888/greendot/admin/";
        }

        this.device_id = window.localStorage.getItem('device_id');
        if (this.device_id == null){
            this.device_id = this.randomString(32);
            window.localStorage.setItem('device_id', this.device_id);
        }

        this.access_token = window.localStorage.getItem('access_token');
        this.user_info = JSON.parse(window.localStorage.getItem('user_info'));

        this.refreshProfile();
    }

    loginAccount(phone, password): Promise<any>{
        let end_point = 'user/login';
        password = CryptoJS.HmacSHA1(password, 'mosaic');

        var result = this.getData(end_point, {phone:phone, password: password});

        result.then(dict => {
            if (dict.code == 200){
                var profile = dict.data;

                this.access_token = profile.access_token;

                window.localStorage.setItem('user_info', JSON.stringify(profile));
                window.localStorage.setItem('access_token', this.access_token);

                this.router.navigate(['home']);
                this.user_info = JSON.parse(window.localStorage.getItem('user_info'));
            }
        });

        return result;
    }

    getAccountList(page, is_admin = 0): Promise<any>{
        let end_point = 'account/list';

        var result = this.getData(end_point, {page: page, is_admin: is_admin});

        return result;
    }

    updateBalance(uid, balance): Promise<any>{
        let end_point = 'account/update';

        var result = this.getData(end_point, {uid: uid, balance: balance});

        return result;
    }

    updateGroup(uid, group_id): Promise<any>{
        let end_point = 'account/update';

        var result = this.getData(end_point, {uid: uid, group_id: group_id});

        return result;
    }

    updateUnlimitedSearch(uid, unlimited_search): Promise<any>{
        let end_point = 'account/update';

        var result = this.getData(end_point, {uid: uid, unlimited_search: unlimited_search});

        return result;
    }

    searchAccount(name,idcard_no,phone,is_admin = 0): Promise<any>{
        let end_point = 'account/search';

        var result = this.getData(end_point, {name: name, idcard_no: idcard_no, phone: phone, is_admin: is_admin});

        return result;
    }

    getShopList(page, name = null, contact_name = null, phone = null): Promise<any>{
        let end_point = 'shop/list';

        var result = this.getData(end_point, {name: name, contact_name: contact_name, phone: phone, page: page});

        return result;
    }

    getOrderList(page, uid = 0, shop_id = 0): Promise<any>{
        let end_point = 'shop/orders';

        var result = this.getData(end_point, {shop_id: shop_id, uid: uid, page: page});

        return result;
    }

    getDiscountList(page): Promise<any>{
        let end_point = 'shop/discounts';

        var result = this.getData(end_point, {page: page});

        return result;
    }

    deleteAccount(uid, start_date = 0, end_date = 0): Promise<any>{
        let end_point = 'account/delete';

        var result = this.getData(end_point, {uid: uid, start_date: start_date, end_date: end_date});

        return result;
    }

    prepareAccount(name,idcard_no,phone,group_id = 0): Promise<any>{
        let end_point = 'account/create';

        var result = this.getData(end_point, {name: name, idcard_no: idcard_no, phone: phone, group_id: group_id});

        return result;
    }

    prepareShopAccount(name, contact_name, phone): Promise<any>{
        let end_point = 'account/prepare';

        var result = this.getData(end_point, {name: name, contact_name: contact_name, phone: phone});

        return result;
    }

    addDiscount(shop_id, discount_type, factor1, factor2): Promise<any> {
        let end_point = 'shop/addDiscount';

        var result = this.getData(end_point, {shop_id: shop_id, discount_type: discount_type, factor1: factor1, factor2: factor2});

        return result;
    }

    removeDiscount(discount_id): Promise<any>{
        let end_point = 'shop/removeDiscount';

        var result = this.getData(end_point, {discount_id: discount_id});

        return result;
    }

    getStaticsInfo(): Promise<any> {
        let end_point = 'summary/all';

        var result = this.getData(end_point, null);

        return result;
    }

    importBlacklist(names, idcard_nos, phones, times): Promise<any>{
        let end_point = 'blacklist/import';

        var result = this.getData(end_point, {name: names.join(), idcard_no: idcard_nos.join(), phone: phones.join(), times: times.join()});

        return result;
    }

    importUsers(names, idcard_nos, phones): Promise<any>{
        let end_point = 'account/import';

        var result = this.getData(end_point, {name: names.join(), idcard_no: idcard_nos.join(), phone: phones.join()});

        return result;
    }

    getBlacklist(page): Promise<any>{
        let end_point = 'blacklist/list';

        var result = this.getData(end_point, {page: page});

        return result;
    }

    searchBlacklist(name,idcard_no,phone,page): Promise<any>{
        let end_point = 'blacklist/search';

        var result = this.getData(end_point, {name: name, idcard_no: idcard_no, phone: phone, page: page});

        return result;
    }

    deleteBlacklist(blacklist_id, start_date = 0, end_date = 0): Promise<any>{
        let end_point = "blacklist/delete";

        var result = this.getData(end_point, {blacklist_id: blacklist_id, start_date: start_date, end_date: end_date});

        return result;
    }

    refreshProfile(): void{
        if (this.access_token != null){
            let end_point = 'user/profile';

            var result = this.getData(end_point, null);

            result.then(dict => {
                if (dict.code == 200){
                    var profile = dict.data;

                    window.localStorage.setItem('user_info', JSON.stringify(profile));

                    this.user_info = JSON.parse(window.localStorage.getItem('user_info'));
                }
            });
        }
    }

    submitProfile(profile: any): Promise<any>{
        let end_point = 'account/submit';

        var result = this.getData(end_point, profile);

        return result;
    }

    getScoresList(name = null, idcard_no = null, phone = null, page = 1): Promise<any>{
        let end_point = 'account/scores';

        var result = this.getData(end_point, {name: name, idcard_no: idcard_no, phone: phone, page: page});

        return result;
    }

    //  Locations
    getLocations(page, phone, name, is_recent = 0): Promise<any>{
        let end_point = 'track/locations';

        var result = this.getData(end_point, {page: page, phone: phone, name: name, is_recent: is_recent});

        return result;
    }

    //  Credit Records
    getCreditRecord(page = 1, name = null, idcard_no = null, phone = null): Promise<any>{
        let end_point = 'user/credit';

        var result = this.getData(end_point, {page: page, idcard_no: idcard_no, name: name, phone: phone});

        return result;
    }

    getData(end_point: string, parameters: any): Promise<any> {
        let url = APIService.BASE_URL + end_point;

        if (parameters == null)
            parameters = {};

        let real_params = this.getRealParameters(parameters);

        let headers      = new Headers({ 'Content-Type': 'application/x-www-form-urlencoded' }); // ... Set content type to JSON
        let options       = new RequestOptions({ headers: headers });

        var param_string = '';

        for (var key in real_params){
            param_string += '&' + key + '=' + real_params[key];
        }

        console.log(url + '?' + encodeURI(param_string));

        var result = this.http.post(url, param_string, options).toPromise().then((response) => {
            var api_response = JSON.parse(response.text());
            if (api_response.data == undefined){
                if (end_point == "shop/discounts")
                    api_response.data = [];
                else
                    api_response.data = {};
            }
            
            return api_response;
        });

        result.then(data => {
            if (data.code == 10006 || data.code == 10007)
                this.logout();
        });

        return result;
    }

    getRealParameters(params: any): any {
        let request_time = Math.trunc(new Date().getTime() / 1000);
        let app_version = APIService.APP_VERSION;
        var real_params: any = {};
        
        real_params.request_time = request_time;
        real_params.app_version = app_version;
        real_params.device_id = this.device_id;

        if (this.access_token != null && this.access_token.length > 0){
            real_params.access_token = this.access_token;
        }else{
            real_params.client_id = APIService.APP_ID;
        }

        for (var key in params){
            if (params[key] != null && params[key] != undefined){
                real_params[key] = params[key];
            }
        }

        real_params['sign'] = this.sign(real_params);

        return real_params;
    }

    sign(parameters: any): string {
        var keys = Object.keys(parameters);
        
        keys.sort();

        var data_string = '';
        for (var i = 0;i < keys.length;i++){
            var key = keys[i];
            data_string += key + '=' + parameters[key];
        }

        var item1 = CryptoJS.MD5(APIService.APP_ID).toString().toUpperCase();
        var item2 = CryptoJS.MD5(this.device_id).toString().toUpperCase();
        var item3 = CryptoJS.MD5(parameters['request_time'].toString()).toString().toUpperCase();

        var key_item:string = CryptoJS.MD5(item1 + item2 + item3).toString().toUpperCase();

        var hash_key:string = CryptoJS.HmacSHA1(key_item,APIService.APP_SECRET).toString().toUpperCase();

        let sign = CryptoJS.HmacSHA1( data_string,hash_key).toString();

        return sign;
    }

    randomString(len: number): string{
        var chars =  'ABCDEFGHJKMNPQRSTWXYZabcdefhijkmnprstwxyz2345678';
        var maxPos = chars.length;
        var result = '';
        for (var i = 0;i < len;i++){
            result += chars.charAt(Math.floor(Math.random() * maxPos));
        }

        return result;
    }

    checkCredentials(): void {
        if (localStorage.getItem('access_token') === null){
            this.router.navigate(['login']);
        }
    }

    logout(): void {
        window.localStorage.removeItem('access_token');
        window.localStorage.removeItem('user_info');
        this.access_token = null;
        this.user_info = null;

        this.router.navigate(['login']);
    }

    navigateTo(page: string): void{
        this.router.navigate([page]);
    }
}