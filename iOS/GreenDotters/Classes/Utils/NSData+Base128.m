//
//  NSData+Base128.m
//  Mosaic
//
//  Created by Stan Wu on 14-5-3.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "NSData+Base128.h"

@implementation NSData (Base128)

- (NSData *)base128DecodedData{
    NSMutableData *origin = [NSMutableData data];
    
    NSUInteger len = self.length;
    if (0==len)
        return nil;
    NSUInteger blob_num = self.length/8+(self.length%8==0?0:1);
    
    unsigned char inBuf[8],outBuf[7];
    const unsigned char *pointer = self.bytes;
    
    for (int i=0;i<blob_num;i++){
        for (int j=0;j<8;j++){
            inBuf[j] = ((i*8+j)<self.length?pointer[i*8+j]:0) & 0x7f;
        }
        // 7 1+6 2+5 3+4 4+3 5+2 6+1 7
        outBuf[0] = (inBuf[0]<<1) | ((inBuf[1] & 0x40)>>6);
        outBuf[1] = ((inBuf[1] & 0x3f)<<2) | ((inBuf[2] & 0x60)>>5);
        outBuf[2] = ((inBuf[2] & 0x1f)<<3) | ((inBuf[3] & 0x70)>>4);
        outBuf[3] = ((inBuf[3] & 0x0f)<<4) | ((inBuf[4] & 0x78)>>3);
        outBuf[4] = ((inBuf[4] & 0x07)<<5) | ((inBuf[5] & 0x7c)>>2);
        outBuf[5] = ((inBuf[5] & 0x03)<<6) | ((inBuf[6] & 0x7e)>>1);
        outBuf[6] = ((inBuf[6] & 0x01)<<7) | (inBuf[7] & 0x7f);
        
        int lastIndex = 0;
        for (int k=6;k>=0;k--){
            if (outBuf[k]!=0){
                lastIndex = k;
                break;
            }
        }
        
        [origin appendBytes:outBuf length:(i<blob_num-1)?7:(lastIndex+1)];
    }
    
    return [NSData dataWithData:origin];
}

- (NSData *)base128EncodedData{
    //  生成自己的文件格式
    unsigned char inBuf[7],outBuf[8];
    
    NSMutableData *base128 = [NSMutableData data];
    NSUInteger blob_num = self.length/7+(self.length%7==0?0:1);
    
    const unsigned char *pointer = self.bytes;
    for (int i=0;i<blob_num;i++){
        for (int j=0;j<7;j++){
            inBuf[j] = (i*7+j)<self.length?pointer[i*7+j]:0;
        }
        //  7+1 6+2 5+3 4+4 3+5 2+6 1+7
        outBuf[0] = (inBuf[0] & 0xfe)>>1;
        outBuf[1] = ((inBuf[0] & 0x1)<<6) | ((inBuf[1] & 0xfc)>>2);
        outBuf[2] = ((inBuf[1] & 0x3)<<5) | ((inBuf[2] & 0xf8)>>3);
        outBuf[3] = ((inBuf[2] & 0x7)<<4) | ((inBuf[3] & 0xf0)>>4);
        outBuf[4] = ((inBuf[3] & 0xf)<<3) | ((inBuf[4] & 0xe0)>>5);
        outBuf[5] = ((inBuf[4] & 0x1f)<<2) | ((inBuf[5] & 0xc0)>>6);
        outBuf[6] = ((inBuf[5] & 0x3f)<<1) | ((inBuf[6] & 0x80)>>7);
        outBuf[7] = inBuf[6] & 0x7f;
        
        int lastIndex = 0;
        for (int k=7;k>=0;k--){
            if (outBuf[k]!=0){
                lastIndex = k;
                break;
            }
        }
        
        [base128 appendBytes:outBuf length:(i<blob_num-1)?8:(lastIndex+1)];
    }
    
    return [NSData dataWithData:base128];
}

@end
