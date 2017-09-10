//
//  Map.m
//  shpRead_ipad_02
//
//  Created by shy on 15/5/4.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import "Map.h"
#import "QCheckBox.h"
#import <math.h>

@implementation Map

-(void)createLayer:(long)count andDelegate:(id<QCheckBoxDelegate>) delegate{
    for(int i=0;i<count;i++){
        QCheckBox *_check3 = [[QCheckBox alloc] initWithDelegate:delegate];
        _check3.frame = CGRectMake(20, 280+i*40, 200, 40);
        [_check3 setTag:i];

        [_check3 setContentMode:UIViewContentModeScaleToFill];
        
        [_check3 setTitle:[NSString stringWithFormat:@"Layer%d-",i+1] forState:UIControlStateNormal];
        [_check3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_check3 setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
        //[_check3 setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
        
        [_check3 setTitleColor: [self getLayerRandomColor] forState:UIControlStateSelected];
        [_check3.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
        [_check3 setImage:[UIImage imageNamed:@"uncheck_icon.png"] forState:UIControlStateNormal];
        [_check3 setImage:[UIImage imageNamed:@"check_icon.png"] forState:UIControlStateSelected];

        [_check3 setChecked:YES];
        
        [_check3 setHidden:YES];
        [layerDisplayButton addObject:_check3];
    }

}

-(void)displayLayers:(long)count andHidden:(BOOL)isHidden{
    for (int i=0; i<count; i++) {
        [(QCheckBox *)[layerDisplayButton objectAtIndex:i] setHidden:isHidden];
    }
}

-(void)setLayerButtonAllChecked:(BOOL)checked{
    for(int i=0;i<[layerDisplayButton count];i++){
        [(QCheckBox *)[layerDisplayButton objectAtIndex:i] setChecked:checked];
    }
}

-(void)updateLayerName:(long)index andName:(NSString *)name{

    QCheckBox *tempBox = (QCheckBox *)[layerDisplayButton objectAtIndex:index];

    [tempBox setTitle:[[NSString stringWithFormat:@"Layer%ld-",++index] stringByAppendingString:name] forState:UIControlStateNormal];
}

-(UIColor *)getLayerRandomColor{
    return [UIColor colorWithRed:(arc4random()%256)/255.0f green:(arc4random()%10)/255.0f blue:(arc4random()%256)/255.0f alpha:1.0];
}

-(int)getShowingLayersCount{
    int num = 0;
    for(int i=0;i<layerDisplayButton.count;i++){
        QCheckBox *tempBox = (QCheckBox *)[layerDisplayButton objectAtIndex:i];
        if([tempBox checked] && ![tempBox isHidden]){
            num++;
        }
    }
    return num;
}

@end
