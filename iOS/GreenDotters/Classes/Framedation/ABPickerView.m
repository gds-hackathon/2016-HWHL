//
//  ABPickerView.m
//  AiBa
//
//  Created by Wu Stan on 12-1-4.
//  Copyright (c) 2012年 CheersDigi. All rights reserved.
//

#import "ABPickerView.h"
#import "GreenDotters-Swift.h"
#import "SWToolKit.h"

@implementation ABPickerView
@synthesize dicInfo,dicProfile,delegate,pickerInfo,pickerDate,lblSelection,dicProfileMate,dicProfileSearch;


- (ABEditType)editType{
    return editType;
}

- (void)setProvince:(int)province city:(int)city{
    [pickerInfo selectRow:province inComponent:0 animated:NO];
    
    NSArray *cities = [[[dicProfile objectForKey:@"city"] objectAtIndex:province] objectForKey:@"cities"];
    NSArray *allcities = [dicProfile objectForKey:@"cities"];
    
    int dcity = -1;
    if (0==city)
        dcity = 0;
    else{
        for (int i=0;i<cities.count;i++){
            if ([[cities objectAtIndex:i] isEqualToString:[allcities objectAtIndex:city]]){
                dcity = i+1;
            }
        }
    }
    [pickerInfo reloadComponent:1];
    [pickerInfo selectRow:dcity>0?dcity:0 inComponent:1 animated:NO];
}

- (void)setEditType:(ABEditType)type{
    editType = type;
    
    pickerInfo.hidden = (ABEditTypeBirthday==type || ABEditTypeDateContent==type);
    pickerDate.hidden = !pickerInfo.hidden;
    [pickerInfo selectRow:0 inComponent:0 animated:NO];
    [pickerInfo reloadAllComponents];
    
    
    pickerDate.datePickerMode = UIDatePickerModeDate;
    if (ABEditTypeBirthday==type){
        NSDate *maxDate = [NSDate dateWithTimeIntervalSinceNow:-3600*24*365*18];
        pickerDate.maximumDate = maxDate;
    }else{
        pickerDate.minimumDate = [[NSDate alloc] init];
        pickerDate.maximumDate = [NSDate dateWithTimeIntervalSinceNow:86400*90];
    }
    
    
    switch (editType) {
        case ABEditTypeHeight:{
            int height = [[dicInfo objectForKey:@"height"] intValue];
            if (height>=120)
                [pickerInfo selectRow:height-120 inComponent:0 animated:NO];
            else
                [pickerInfo selectRow:25 inComponent:0 animated:NO];
        }
            break;
        case ABEditTypeWeight:{
            int weight = [[dicInfo objectForKey:@"weight"] intValue];
            if (weight>=40)
                [pickerInfo selectRow:weight-40 inComponent:0 animated:NO];
            else
                [pickerInfo selectRow:10 inComponent:0 animated:NO];
        }
            break;
        case ABEditTypeMateAge:{
            [pickerInfo selectRow:5 inComponent:0 animated:NO];
            [pickerInfo selectRow:12 inComponent:1 animated:NO];
        }
            break;
        case ABEditTypeMateHeight:{
            [pickerInfo selectRow:41 inComponent:0 animated:NO];
            [pickerInfo selectRow:61 inComponent:1 animated:NO];
        }
            break;
        case ABEditTypeMateWeight:{
            [pickerInfo selectRow:5 inComponent:0 animated:NO];
            [pickerInfo selectRow:10 inComponent:1 animated:NO];
        }
            break;
        case ABEditTypeBirthday:
            lblSelection.text = NSLocalizedString(@"请选择出生日期", @"请选择出生日期");
            break;
        default:
            break;
    }
}
    


- (id)initWithFrame:(CGRect)frame
{
    frame.size.width = ScreenWidth;
    frame.size.height = 260;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        dMaxAge = 80;
        dMinAge = 18;
        dMaxHeight = 250;
        dMinHeight = 120;
        dMinWeight = 40;
        dMaxWeight = 200;
        NSDictionary *dict = [MDataProvider profilePlist];
        self.dicProfile = [dict objectForKey:@"profile"];
        self.dicProfileMate = [dict objectForKey:@"mate"];
        self.dicProfileSearch = [dict objectForKey:@"search"];
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
//        toolbar.barStyle = UIBarStyleBlackOpaque;
        [self addSubview:toolbar];
        toolbar.userInteractionEnabled = YES;
        toolbar.backgroundColor = [UIColor colorWithWhite:.96 alpha:1];
        
        lblSelection = [UILabel createLabelWithFrame:CGRectMake(0, 0, ScreenWidth, 44) font:[UIFont systemFontOfSize:14] textColor:[UIColor grayColor]];
        lblSelection.textAlignment = NSTextAlignmentCenter;
        [toolbar addSubview:lblSelection];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"ABNavButtonBG.png"] forState:UIControlStateNormal];
        [btn sizeToFit];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitle:NSLocalizedString(@"取消", @"取消") forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
        btn.center = CGPointMake(10+btn.frame.size.width/2, 22);
        [self addSubview:btn];
//        btn.hidden = YES;
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"ABNavButtonBG.png"] forState:UIControlStateNormal];
        [btn sizeToFit];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitle:NSLocalizedString(@"确定", @"确定") forState:UIControlStateNormal];
        [btn setTitleColor:PURPLE_COLOR forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(confirmClicked) forControlEvents:UIControlEventTouchUpInside];
        btn.center = CGPointMake(ScreenWidth-10-btn.frame.size.width/2, 22);
        [self addSubview:btn];
//        btn.hidden = YES;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue]<7) {
            NSMutableArray *barItems = [[NSMutableArray alloc] init];
            UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"取消", @"取消") style:UIBarButtonItemStylePlain target:self action:@selector(cancelClicked)];
            [barItems addObject:cancelBtn];
            
            UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
            [barItems addObject:flexSpace];
            
            UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"完成", @"完成") style:UIBarButtonItemStyleDone target:self action:@selector(confirmClicked)];
            [barItems addObject:doneBtn];
            [toolbar setItems:barItems animated:YES];
        }
        
        pickerInfo = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, ScreenWidth, 216)];
        pickerInfo.backgroundColor = [UIColor whiteColor];
        pickerInfo.showsSelectionIndicator = YES;
        pickerInfo.delegate = self;
        pickerInfo.dataSource = self;
        [self addSubview:pickerInfo];
        
        pickerDate = [[UIDatePicker alloc] initWithFrame:pickerInfo.frame];
        [pickerDate addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
        pickerDate.datePickerMode = UIDatePickerModeDate;
        [self addSubview:pickerDate];
    }
    return self;
}


- (void)cancelClicked{
    [delegate pickerDidCancelSelection:self];
}

- (void)confirmClicked{
    [delegate pickerDidFinishSelection:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark -
#pragma mark UIPickerView Delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSArray *ary = nil;
    NSString *title = nil;
    
    switch (editType) {
        case ABEditTypeBirthday:
        case ABEditTypeDateContent:{
            
        }
            break;
        case ABEditTypeHeight:{
            NSMutableArray *mut = [NSMutableArray array];
            for (int i=150;i<=210;i++)
                [mut addObject:[NSString stringWithFormat:@"%dCM",i]];
            ary = [NSArray arrayWithArray:mut];
        }
            break;
        case ABEditTypeWeight:{
            NSMutableArray *mut = [NSMutableArray array];
            for (int i=40;i<=100;i++)
                [mut addObject:[NSString stringWithFormat:@"%dKG",i]];
            ary = [NSArray arrayWithArray:mut];
        }
            break;
        case ABEditTypeNation:{
            ary = [dicProfile objectForKey:@"nation_id"];
        }
            break;
        case ABEditTypeConstellation:{
            ary = [dicProfile objectForKey:@"zodiac_sign"];
        }
            break;
        case ABEditTypeCharmPart:{
            ary = [dicProfile objectForKey:@"charm_part"];
        }
            break;
        case ABEditTypeLoveAttitude:{
            ary = [dicProfile objectForKey:@"love_attitude"];
        }
            break;
        case ABEditTypeSexAttitude:{
            ary = [dicProfile objectForKey:@"sex_attitude"];
        }
            break;
        case ABEditTypeMarriageStatus:{
            ary = [dicProfile objectForKey:@"marriage_status"];
        }
            break;
        case ABEditTypeHasKids:{
            ary = [dicProfile objectForKey:@"has_kids"];
        }
            break;
        case ABEditTypeMarriageDuration:{
            ary = [dicProfile objectForKey:@"marriage_duration"];
        }
            break;
        case ABEditTypeArea:
        case ABEditTypeNativeArea:
        case ABEditTypeMateArea:
        case ABEditTypeMateNativeArea:
        case ABEditTypeSearchArea:
        case ABEditTypeSearchNativeArea:{
            NSInteger index = [pickerView selectedRowInComponent:0];
            if (0==component)
                title = [[dicProfile objectForKey:@"provinces"] objectAtIndex:row];
            else{
                if (0==row)
                    title = NSLocalizedString(@"未填", @"未填");
                else{
                    NSArray *ary = [[[dicProfile objectForKey:@"city"] objectAtIndex:index] objectForKey:@"cities"];
                    
                    title = row-1<ary.count?[ary objectAtIndex:row-1]:nil;
                }
            }
        }
        case ABEditTypeEducation:
        case ABEditTypeMateEducation:
        case ABEditTypeSearchEducation:{
            ary = [dicProfile objectForKey:@"education"];
        }
            break;
        case ABEditTypeSchool:{
            
        }
            break;
        case ABEditTypeWork:{
            ary = [dicProfile objectForKey:@"job"];
        }
            break;
        case ABEditTypeSalary:
        case ABEditTypeMateSalary:
        case ABEditTypeSearchSalary:{
            ary = [dicProfile objectForKey:@"salary"];
        }
            break;
        case ABEditTypeHouse:
            ary = [dicProfile objectForKey:@"house"];
            break;
        case ABEditTypeMateHouse:
        case ABEditTypeSearchHouse:{
            ary = [dicProfileSearch objectForKey:@"house_status"];
        }
            break;
        
//        case ABEditTypePersonal:{
//            ary = [dicProfile objectForKey:@"personal"];
//        }
//            break;
        case ABEditTypeBlood:{
            ary = [dicProfile objectForKey:@"blood"];
        }
            break;
        case ABEditTypeWedlock:
        case ABEditTypeMateWedlock:
        case ABEditTypeSearchWedlock:{
            ary = [dicProfile objectForKey:@"wedlock"];
        }
            break;
        case ABEditTypeStatus:{
            ary = [dicProfile objectForKey:@"status"];
        }
            break;
            
        
        case ABEditTypeMateAge:
        case ABEditTypeSearchAge:{
            if (0==component){
                NSMutableArray *mut = [NSMutableArray array];
                [mut addObject:NSLocalizedString(@"不限", @"不限")];
                for (int i=18;i<=dMaxAge;i++)
                    [mut addObject:[NSString stringWithFormat:NSLocalizedString(@">=%d岁", @">=%d岁"),i]];
                ary = [NSArray arrayWithArray:mut];
            }
                
            else{
                NSMutableArray *mut = [NSMutableArray array];
                [mut addObject:NSLocalizedString(@"不限", @"不限")];
                for (int i=dMinAge;i<=80;i++)
                    [mut addObject:[NSString stringWithFormat:NSLocalizedString(@"<=%d岁", @"<=%d岁"),i]];
                ary = [NSArray arrayWithArray:mut];
            }
        }
            break;
        case ABEditTypeMateHeight:
        case ABEditTypeSearchHeight:{
            if (0==component){
                NSMutableArray *mut = [NSMutableArray array];
                [mut addObject:NSLocalizedString(@"不限", @"不限")];
                for (int i=120;i<=dMaxHeight;i++)
                    [mut addObject:[NSString stringWithFormat:@">=%dCM",i]];
                ary = [NSArray arrayWithArray:mut];
            }
            else{
                NSMutableArray *mut = [NSMutableArray array];
                [mut addObject:NSLocalizedString(@"不限", @"不限")];
                for (int i=dMinHeight;i<=250;i++)
                    [mut addObject:[NSString stringWithFormat:@"<=%dCM",i]];
                ary = [NSArray arrayWithArray:mut];
            }
        }
            break;
        case ABEditTypeMateWeight:{
            if (0==component){
                NSMutableArray *mut = [NSMutableArray array];
                [mut addObject:NSLocalizedString(@"不限", @"不限")];
                for (int i=40;i<=dMaxWeight;i++)
                    [mut addObject:[NSString stringWithFormat:@">=%dKG",i]];
                ary = [NSArray arrayWithArray:mut];
            }
            else{
                NSMutableArray *mut = [NSMutableArray array];
                [mut addObject:NSLocalizedString(@"不限", @"不限")];
                for (int i=dMinWeight;i<=200;i++)
                    [mut addObject:[NSString stringWithFormat:@"<=%dKG",i]];
                ary = [NSArray arrayWithArray:mut];
            }
        }
            break;
        case ABEditTypeMateLevel:
        case ABEditTypeSearchLevel:{
            NSMutableArray *mut = [NSMutableArray array];
            for (int i=0;i<=5;i++){
                if (0!=i)
                    [mut addObject:[NSString stringWithFormat:NSLocalizedString(@"%d或以上", @"%d或以上"),i]];
                else
                    [mut addObject:NSLocalizedString(@"不限", @"不限")];
            }
            ary = [NSArray arrayWithArray:mut];
        }
            break;
        case ABEditTypeSearchGender:{
            ary = [NSArray arrayWithObjects:NSLocalizedString(@"男", @"男"),NSLocalizedString(@"女", @"女"), nil];
        }
            break;
        case ABEditTypeSearchAuth:{
            ary = [NSArray arrayWithObjects:NSLocalizedString(@"不限", @"不限"),NSLocalizedString(@"有", @"有"), nil];
        }
            break;
        default:
            break;
    }
        

    
    if (!title && [ary count]>row)
        title = [ary objectAtIndex:row];
    
    if (!title)
        title = NSLocalizedString(@"未填", @"未填");
    
    return title;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSArray *ary = nil;

    
    switch (editType) {
        case ABEditTypeBirthday:
        case ABEditTypeDateContent:{
            
        }
            break;
        case ABEditTypeHeight:{
            NSMutableArray *mut = [NSMutableArray array];
            for (int i=150;i<=210;i++)
                [mut addObject:[NSString stringWithFormat:@"%dCM",i]];
            ary = [NSArray arrayWithArray:mut];
        }
            break;
        case ABEditTypeWeight:{
            NSMutableArray *mut = [NSMutableArray array];
            for (int i=40;i<=100;i++)
                [mut addObject:[NSString stringWithFormat:@"%dKG",i]];
            ary = [NSArray arrayWithArray:mut];
        }
            break;
        case ABEditTypeNation:{
            ary = [dicProfile objectForKey:@"nation_id"];
        }
            break;
        case ABEditTypeConstellation:{
            ary = [dicProfile objectForKey:@"zodiac_sign"];
        }
            break;
        case ABEditTypeCharmPart:{
            ary = [dicProfile objectForKey:@"charm_part"];
        }
            break;
        case ABEditTypeLoveAttitude:{
            ary = [dicProfile objectForKey:@"love_attitude"];
        }
            break;
        case ABEditTypeSexAttitude:{
            ary = [dicProfile objectForKey:@"sex_attitude"];
        }
            break;
        case ABEditTypeMarriageStatus:{
            ary = [dicProfile objectForKey:@"marriage_status"];
        }
            break;
        case ABEditTypeHasKids:{
            ary = [dicProfile objectForKey:@"has_kids"];
        }
            break;
        case ABEditTypeMarriageDuration:{
            ary = [dicProfile objectForKey:@"marriage_duration"];
        }
            break;
        case ABEditTypeArea:
        case ABEditTypeNativeArea:
        case ABEditTypeMateArea:
        case ABEditTypeMateNativeArea:
        case ABEditTypeSearchArea:
        case ABEditTypeSearchNativeArea:{
            if (0==component)
                return [[dicProfile objectForKey:@"city"] count];
            else{
                NSInteger index = [pickerView selectedRowInComponent:0];
                return [[[[dicProfile objectForKey:@"city"] objectAtIndex:index] objectForKey:@"cities"] count]+1;
            }
        }
        case ABEditTypeEducation:
        case ABEditTypeMateEducation:
        case ABEditTypeSearchEducation:{
            ary = [dicProfile objectForKey:@"education"];
        }
            break;
        case ABEditTypeSchool:{
            
        }
            break;
        case ABEditTypeWork:{
            ary = [dicProfile objectForKey:@"job"];
        }
            break;
        case ABEditTypeSalary:
        case ABEditTypeMateSalary:
        case ABEditTypeSearchSalary:{
            ary = [dicProfile objectForKey:@"salary"];
        }
            break;
        case ABEditTypeHouse:
            ary = [dicProfile objectForKey:@"house"];
            break;
        case ABEditTypeMateHouse:
        case ABEditTypeSearchHouse:{
            ary = [self.dicProfileMate objectForKey:@"house_status"];
        }
            break;
//        case ABEditTypePersonal:{
//            ary = [dicProfile objectForKey:@"personal"];
//        }
//            break;
        case ABEditTypeBlood:{
            ary = [dicProfile objectForKey:@"blood"];
        }
            break;
        case ABEditTypeWedlock:
        case ABEditTypeMateWedlock:
        case ABEditTypeSearchWedlock:{
            ary = [dicProfile objectForKey:@"wedlock"];
        }
            break;
        case ABEditTypeStatus:{
            ary = [dicProfile objectForKey:@"status"];
        }
            break;
        case ABEditTypeMateAge:
        case ABEditTypeSearchAge:{
            if (0==component){
                NSMutableArray *mut = [NSMutableArray array];
                [mut addObject:NSLocalizedString(@"不限", @"不限")];
                for (int i=18;i<=dMaxAge;i++)
                    [mut addObject:[NSString stringWithFormat:NSLocalizedString(@">=%d岁", @">=%d岁"),i]];
                ary = [NSArray arrayWithArray:mut];
            }
            
            else{
                NSMutableArray *mut = [NSMutableArray array];
                [mut addObject:NSLocalizedString(@"不限", @"不限")];
                for (int i=dMinAge;i<=80;i++)
                    [mut addObject:[NSString stringWithFormat:NSLocalizedString(@"<=%d岁", @"<=%d岁"),i]];
                ary = [NSArray arrayWithArray:mut];
            }
        }
            break;
        case ABEditTypeMateHeight:
        case ABEditTypeSearchHeight:{
            if (0==component){
                NSMutableArray *mut = [NSMutableArray array];
                [mut addObject:NSLocalizedString(@"不限", @"不限")];
                for (int i=120;i<=dMaxHeight;i++)
                    [mut addObject:[NSString stringWithFormat:@">=%dCM",i]];
                ary = [NSArray arrayWithArray:mut];
            }
            else{
                NSMutableArray *mut = [NSMutableArray array];
                [mut addObject:NSLocalizedString(@"不限", @"不限")];
                for (int i=dMinHeight;i<=220;i++)
                    [mut addObject:[NSString stringWithFormat:@"<=%dCM",i]];
                ary = [NSArray arrayWithArray:mut];
            }
        }
            break;
        case ABEditTypeMateWeight:{
            if (0==component){
                NSMutableArray *mut = [NSMutableArray array];
                [mut addObject:NSLocalizedString(@"不限", @"不限")];
                for (int i=40;i<=dMaxWeight;i++)
                    [mut addObject:[NSString stringWithFormat:@">=%dKG",i]];
                ary = [NSArray arrayWithArray:mut];
            }
            else{
                NSMutableArray *mut = [NSMutableArray array];
                [mut addObject:NSLocalizedString(@"不限", @"不限")];
                for (int i=dMinWeight;i<=200;i++)
                    [mut addObject:[NSString stringWithFormat:@"<=%dKG",i]];
                ary = [NSArray arrayWithArray:mut];
            }
        }
            break;
        case ABEditTypeMateLevel:
        case ABEditTypeSearchLevel:{
            NSMutableArray *mut = [NSMutableArray array];
            for (int i=0;i<=5;i++){
                if (0!=i)
                    [mut addObject:[NSString stringWithFormat:NSLocalizedString(@"%d或以上", @"%d或以上"),i]];
                else
                    [mut addObject:NSLocalizedString(@"不限", @"不限")];
            }
            ary = [NSArray arrayWithArray:mut];
        }
            break;
        case ABEditTypeSearchGender:{
            ary = [NSArray arrayWithObjects:NSLocalizedString(@"男", @"男"),NSLocalizedString(@"女", @"女"), nil];
        }
            break;
        case ABEditTypeSearchAuth:{
            ary = [NSArray arrayWithObjects:NSLocalizedString(@"不限", @"不限"),NSLocalizedString(@"有", @"有"), nil];
        }
            break;
        default:
            break;
    }
    

    
    return [ary count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if (ABEditTypeMateAge==editType || ABEditTypeSearchAge==editType ||
        ABEditTypeMateHeight==editType || ABEditTypeSearchHeight==editType ||
        ABEditTypeMateWeight == editType ||
        ABEditTypeArea==editType || ABEditTypeMateArea==editType || ABEditTypeSearchArea==editType ||
        ABEditTypeNativeArea==editType || ABEditTypeMateNativeArea==editType || ABEditTypeSearchNativeArea==editType)
        return 2;
    else
        return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (ABEditTypeMateAge==editType || ABEditTypeSearchAge==editType){
        NSString *title = [self pickerView:pickerView titleForRow:row forComponent:component];
        int count = 0;
        if ([[title componentsSeparatedByString:@"="] count]>1){
            count = [[[title componentsSeparatedByString:@"="] objectAtIndex:1] intValue];
        }
        
        if (0==component){
            int min = count;
            if (0!=min)
                dMinAge = min;
            if (dMaxAge<dMinAge)
                dMaxAge = dMinAge;
        }else{
            int max = count;
            if (0!=max)
                dMaxAge = max;
            if (dMinAge>dMaxAge)
                dMinAge = dMaxAge;
        }
        
        [pickerView reloadAllComponents];
        if (0==component){
            int index = count+9-dMinAge;
            if (index>=0 && index<[self pickerView:pickerView numberOfRowsInComponent:1]){
                [pickerView selectRow:index inComponent:1 animated:NO];
            }
        }
    }else if (ABEditTypeMateHeight==editType || ABEditTypeSearchHeight==editType){
        NSString *title = [self pickerView:pickerView titleForRow:row forComponent:component];
        int count = 0;
        if ([[title componentsSeparatedByString:@"="] count]>1){
            count = [[[title componentsSeparatedByString:@"="] objectAtIndex:1] intValue];
        }
        
        if (0==component){
            int min = count;
            if (0!=min)
                dMinHeight = min;
            if (dMaxHeight<dMinHeight)
                dMaxHeight = dMinHeight;
        }else{
            int max = count;
            if (0!=max)
                dMaxHeight = max;
            if (dMinHeight>dMaxHeight)
                dMinHeight = dMaxHeight;
        }
        
        [pickerView reloadAllComponents];
        if (0==component){
            int index = count+11-dMinHeight;
            if (index>=0 && index<[self pickerView:pickerView numberOfRowsInComponent:1]){
                [pickerView selectRow:index inComponent:1 animated:NO];
            }
        }
    }else if (ABEditTypeMateWeight==editType){
        NSString *title = [self pickerView:pickerView titleForRow:row forComponent:component];
        int count = 0;
        if ([[title componentsSeparatedByString:@"="] count]>1){
            count = [[[title componentsSeparatedByString:@"="] objectAtIndex:1] intValue];
        }
        
        if (0==component){
            int min = count;
            if (0!=min)
                dMinWeight = min;
            if (dMaxWeight<dMinWeight)
                dMaxWeight = dMinWeight;
        }else{
            int max = count;
            if (0!=max)
                dMaxWeight = max;
            if (dMinWeight>dMaxWeight)
                dMinWeight = dMaxWeight;
        }
        
        [pickerView reloadAllComponents];
        if (0==component){
            int index = count+11-dMinWeight;
            if (index>=0 && index<[self pickerView:pickerView numberOfRowsInComponent:1]){
                [pickerView selectRow:index inComponent:1 animated:NO];
            }
        }
    }else if (ABEditTypeArea==editType || ABEditTypeMateArea==editType || ABEditTypeSearchArea==editType || ABEditTypeNativeArea==editType || ABEditTypeMateNativeArea==editType || ABEditTypeSearchNativeArea==editType)
        [pickerView reloadComponent:1];
    
    [delegate pickerDidChangedSelection:self];
}

- (void)dateChanged{
    [delegate pickerDidChangedSelection:self];
}

- (void)setDate:(NSDate *)date{
    [pickerDate setDate:date];
}
@end
