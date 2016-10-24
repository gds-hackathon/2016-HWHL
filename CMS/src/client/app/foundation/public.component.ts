import { Component } from '@angular/core';
import { APIService } from '../services/api.service';

export class PublicComponent { 
    constructor(public apiService: APIService) {}

    error_message;

    showErrorMessage(str): void{
        this.error_message = str;

        setTimeout(()=>{
            this.error_message = null;
        }, 3000);
    }
}