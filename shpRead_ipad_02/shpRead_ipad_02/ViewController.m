//
//  ViewController.m
//  shpRead_ipad_02
//
//  Created by shy on 15/4/5.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import <math.h>
#import "ViewController.h"
#import "ShowView.h"
#import "ShowView+FrameMethods.h"
#import "Dbffile.h"
#import "Shxfile.h"
#import "MeasureUtil.h"
#import "orthographic_projection_oc.h"
#import "Mercator_projection.h"
#import "KxMenu.h"
#import "QCheckBox.h"
#import "ShpHelper.h"
#import "Map.h"
#import "ShapePolyline.h"
#import "ViewHelper.h"
#import "SearchHelper.h"
#import "orthographic_projectionHelper.h"
#import "MapRenderer.h"


#define RecognizeCheckedTag 20
#define AttrCheckedTag 30
#define PointRange 1

@interface ViewController (){
    @private
    CGPoint originPos_temp;
    double x;
    double y;
    //保存上一次点击的位置
    NSString *strTemp;
    
}

@end

@implementation ViewController


#pragma mark -lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    [location setHidden:YES];
    [distanceLabel setHidden:YES];
    searchResultDisplay.text = @"";
    
    x = y = 0;

    map = [[Map alloc] init];
    map->layerData = [[NSMutableArray alloc] init];
    map->layerDisplayButton = [[NSMutableArray alloc] init];
    //create
    [map createLayer:LAYERNUM andDelegate:self];
    for (int i=0; i<[map->layerDisplayButton count]; i++) {
        [self.view addSubview:(QCheckBox *)[map->layerDisplayButton objectAtIndex:i]];
    }
    
    //初始化
    showView->map = [[Map alloc] init];
    showView->originScale = 1.0;
    showView->coordinate_scale = 1.0;
    showView->offset.x = 0;
    showView->offset.y = 0;
    showView->isMeasuring = NO;
    showView->isSearching = NO;
    showView->recognizeHilightChecked = NO;
    showView->recognizeHilightIndex = 0;
    showView->AttrDisplayChecked = NO;
    showView->util =[[MeasureUtil alloc] init];
    showView->orthographic_projection= [[orthographic_projection_oc alloc] init];
    showView->mercator_projection = [[Mercator_projection alloc] init];
    
//    [showView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight];
    //创建按钮
    [self.view addSubview:[ViewHelper createCheckedButton:24 andY:200 andWidth:50 andHeight:40 andTitle:@"识别" andTag:RecognizeCheckedTag andChecked:YES andDelegate:self]];
    [self.view addSubview:[ViewHelper createCheckedButton:80 andY:200 andWidth:50 andHeight:40 andTitle:@"属性" andTag:AttrCheckedTag andChecked:YES andDelegate:self]];
       
    // these two labels will be updated with an IBAction method which is linked to slider's UIControlEventValueChanged event
//    _continuousValueLabel.text = [NSString stringWithFormat:@"%.2f", _continuousSlider.value];
//    _steppedValueLabel.text = [NSString stringWithFormat:@"%.2f", _steppedSlider.value];

    //修改uiSwithch的圆形按钮的颜色
    
    measureSwitch.thumbTintColor = [MapRenderer getColor];
    
    [measureSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    [projectionPattern addTarget:self action:@selector(chooseProj:) forControlEvents:UIControlEventTouchUpInside];
    
    [projectionCenter addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    [open addTarget:self action:@selector(openMenu:) forControlEvents:UIControlEventTouchUpInside];
    //设置所有菜单项的字体，如果不设置，就采用默认的字体（代码中有体现）
    [KxMenu setTitleFont:[UIFont systemFontOfSize:14]];
    
    //添加手势
    //tap
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapGestureRecognizer addTarget:self action:@selector(tapGestureRecognizerHandle:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [tapGestureRecognizer setDelegate:self];
    [showView addGestureRecognizer:tapGestureRecognizer];
    
    
    //缩放
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] init];
    [pinchGestureRecognizer addTarget:self action:@selector(scaleGestureRecognizerHandle:)];
    [pinchGestureRecognizer setDelegate:self];
    [showView addGestureRecognizer:pinchGestureRecognizer];
    
    //drag
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
    [panGestureRecognizer addTarget:self action:@selector(dragGestureRecognizerHandle:)];
    [panGestureRecognizer setMinimumNumberOfTouches:1];
    [panGestureRecognizer setMaximumNumberOfTouches:5];
    [panGestureRecognizer setDelegate:self];
    [showView addGestureRecognizer:panGestureRecognizer];
    
    
    //rotate
    UIRotationGestureRecognizer *rotatationGestureRecognizer = [[UIRotationGestureRecognizer alloc] init];
    [rotatationGestureRecognizer addTarget:self action:@selector(rotationGestureRecognizerHandle:)];
    [rotatationGestureRecognizer setDelegate:self];
    [showView addGestureRecognizer:rotatationGestureRecognizer];



    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- openclick
-(IBAction)openClick:(id)sender{
    //先从指定位置加载
    NSString *resourceP = [[NSBundle mainBundle] resourcePath];
    NSString *targetPath = @"/dituData/shengjie_region";
//    NSString *targetPath = @"/dituData/World_countries_shp";
    //NSString *targetPath = @"/dituData/esriWorkMap/Countries";
    
    NSString *strFileNameWithPath = [resourceP stringByAppendingString:targetPath];
    
    //加载省会文件
    NSString *CaptitalPath = @"/dituData/shenghui_point";
    NSString *captical_strFileNameWithPath = [resourceP stringByAppendingString:CaptitalPath];
    
    Layer *shpLayer = [[Layer alloc] init];
    
    //打开省界文件
    shpLayer->shpsLayer = [self openShapefile:[strFileNameWithPath stringByAppendingString:@".shp"]];
    shpLayer->dbfLayer = [self openDbffile:[strFileNameWithPath stringByAppendingString:@".dbf"]];
    shpLayer->shpsLayer->shp_shxFile = [self openShxfile:[strFileNameWithPath stringByAppendingString:@".shx"]];
    
    
    Layer *shpLayer_shenghui = [[Layer alloc] init];
    //打开省会文件
    shpLayer_shenghui->shpsLayer = [self openShapefile:[captical_strFileNameWithPath stringByAppendingString:@".shp"]];
    shpLayer_shenghui->dbfLayer = [self openDbffile:[captical_strFileNameWithPath stringByAppendingString:@".dbf"]];
    shpLayer_shenghui->shpsLayer->shp_shxFile = [self openShxfile:[captical_strFileNameWithPath stringByAppendingString:@".shx"]];
    
    
    
    //添加图层
    
    [map->layerData addObject:shpLayer];
    [map->layerData addObject:shpLayer_shenghui];
    
    
    showView->map = map;
    Layer *baseLayer = (Layer *)[map->layerData objectAtIndex:0];
    Shapefile *baseShp = baseLayer->shpsLayer;
    showView->extendLeft = [baseShp extendLeft];
    showView->extendBottom = [baseShp extendBottom];
    showView->extendRight = [baseShp extendRight];
    showView->extendTop = [baseShp extendTop];
    //绘制
    
    [showView setNeedsDisplay];

}

#pragma mark-resetclick
-(IBAction)resetClick:(id)sender{
    
    [self reset];
}

#pragma mark- 搜索功能
-(IBAction)search:(id)sender{
    //取反
    showView->isSearching = ~showView->isSearching;
    if(showView->isSearching){
        search.tintColor = [UIColor blueColor];
    }else{
        search.tintColor = [UIColor grayColor];
        return;
    }
    
    if (searchAlertView==nil) {
        searchAlertView = [[UIAlertView alloc] initWithTitle:@"搜索" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil ,nil];
    }
    [searchAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *nameField = [searchAlertView textFieldAtIndex:0];
    nameField.keyboardType = UIKeyboardTypeDefault;
    //nameField.keyboardAppearance
    nameField.placeholder = @"请输入经纬度或地名";
//    UITextField *urlField = [searchAlertView textFieldAtIndex:1];
//    [urlField setSecureTextEntry:NO];
//    urlField.placeholder = @"请输入一个URL";
//    urlField.text = @"http://";
    [searchAlertView show];
}

#pragma mark- clearClick
-(IBAction)clearClick:(id)sender{
    searchResultDisplay.text = @"";
    showView->isSearching = NO;
    [showView setNeedsDisplay];
}

#pragma mark-复位
-(void)reset{
    showView->coordinate_scale = 1;
    showView->originScale = 1;
    showView->offset.x = 0;
    showView->offset.y = 0;
    showView->angel = 0;
    location.text = @"";
    distanceLabel.text = @"";
    showView.transform = CGAffineTransformIdentity;

    //[showView setNeedsDisplay];
}

#pragma mark-exitclick
-(IBAction)exitClick:(id)sender{

}


#pragma mark- openfunctions
-(Shapefile *)openShapefile:(NSString *)strShapefile{
    
    
    Shapefile *shapefile = [[Shapefile alloc] init];

    //load shapeFile 转载并解析文件
    BOOL bLoad = [shapefile loadShapefile:strShapefile];
    //load success
    if(bLoad)
    {


    }
    
    return  shapefile;
}

-(Dbffile *)openDbffile:(NSString *)strDbffile{
    Dbffile *dbffile = [[Dbffile alloc] init];
    
    //load shapeFile 转载并解析文件
    BOOL bLoad = [dbffile loadDbffile:strDbffile];
    //load success 读取完dbfFile
    if(bLoad)
    {
        
    }
    return dbffile;
    
}

-(Shxfile *)openShxfile:(NSString *)strShxfile{
    Shxfile *shxFile = [[Shxfile alloc] init];
    //load shapeFile 转载并解析文件
    BOOL bLoad = [shxFile loadShxfile:strShxfile];
    //load success 读取完dbfFile
    if(bLoad)
    {
        
    }
    return shxFile;
    
}

//tap
#pragma mark- gesture
-(void)tapGestureRecognizerHandle:(id)recognizer  {
    NSLog(@"Tap-----Begin");
    double lon = 0,lat = 0;
    BOOL done = 1;
    Layer *layerTemp;
    CGPoint clickPos;
    NSString *attrInfo;
    //保存attrInfo的首都或所在国家
    NSString *str = @"";
    UITapGestureRecognizer *recognizerTemp = (UITapGestureRecognizer *)recognizer;
    CGPoint point = [recognizerTemp locationInView:showView];

    showView->currentTap = point;
    
    if(showView->projectionPattern == TwoDimentionsProjectionPattern){
        //平移
        double ges_scale = showView->pScale;
        NSLog(@".......Click....loc: X:%f and Y:%f",point.x,point.y);
        //clickPos 为quartz  2D coordinate  转换到quart 2D的坐标系
        clickPos = CGPointMake((point.x-showView.bounds.size.width/2)/showView->originScale,((point.y-showView.bounds.size.height/2)*(-1))/showView->originScale);

        lon = (clickPos.x/ges_scale) + (showView->extendLeft+showView->extendRight)/2;
        lat = ((clickPos.y)/ges_scale) + (showView->extendBottom+showView->extendTop)/2;
    
        
        attrInfo = [self getAttrInfoByLayer:(Layer *)map->layerData  withLayerIndex:1 withAttrIndex:0 withLon:lon andLat:lat andOutputPolygonIndex:&(showView->recognizeHilightIndex)];
        showView->recognizeHilightLayerIndex = 1;
        if([attrInfo isEqualToString:@""]){
            showView->recognizeHilightLayerIndex = 0;
            attrInfo = [self getAttrInfoByLayer:(Layer *)map->layerData  withLayerIndex:0 withAttrIndex:0 withLon:lon andLat:lat andOutputPolygonIndex:&(showView->recognizeHilightIndex)];
        }
        //依据经纬度得到属性信息
        if(lon >= 180)
            lon = 180;
        if(lon <= -180)
            lon = -180;
        if(lat >= 90)
            lat = 90;
        if(lat <= -90)
            lat = -90;
        location.text = [NSString stringWithFormat:@"经度:%.2f 纬度:%.2f",lon,lat];
        position.text = [NSString stringWithFormat:@"%@",attrInfo];

    }else if(showView->projectionPattern == OrthographicProjectionPattern){
        //ChinaMap--OrthographicProjectionPattern
        if(showView->mapDispalyType == ChinaMap){
            clickPos = CGPointMake((point.x-showView.bounds.size.width/2)/showView->originScale,((point.y-showView.bounds.size.height/2)*(-1))/showView->originScale);
            clickPos.x *= showView->pScale;
            clickPos.y *= showView->pScale;
            done = [showView->orthographic_projection xy_to_transit:&lat andLon:&lon andX:clickPos.x andY:clickPos.y];
            if(!done){
                return;
            }
            lat = h2j(lat);
            lon = h2j(lon);
            attrInfo = [self getAttrInfoByLayer:(Layer *)map->layerData  withLayerIndex:1 withAttrIndex:0 withLon:lon andLat:lat andOutputPolygonIndex:&(showView->recognizeHilightIndex)];
            showView->recognizeHilightLayerIndex = 1;
            if([attrInfo isEqualToString:@""]){
                showView->recognizeHilightLayerIndex = 0;
                attrInfo = [self getAttrInfoByLayer:(Layer *)map->layerData  withLayerIndex:0 withAttrIndex:0 withLon:lon andLat:lat andOutputPolygonIndex:&(showView->recognizeHilightIndex)];
            }
            location.text = [NSString stringWithFormat:@"经度:%.2f 纬度:%.2f",lon,lat];
            position.text = [NSString stringWithFormat:@"%@",attrInfo];
        }else{
        //WorldMap--OrthographicProjectionPattern
            clickPos = CGPointMake((point.x-showView.bounds.size.width/2)/showView->originScale,((point.y-showView.bounds.size.height/2)*(-1))/showView->originScale);
            clickPos.x *= showView->pScale;
            clickPos.y *= showView->pScale;
            done = [showView->orthographic_projection xy_to_transit:&lat andLon:&lon andX:clickPos.x andY:clickPos.y];
            if(!done){
                return;
            }
            lat = h2j(lat);
            lon = h2j(lon);
            attrInfo = [self getAttrInfoByLayer:(Layer *)map->layerData  withLayerIndex:1 withAttrIndex:0 withLon:lon andLat:lat andOutputPolygonIndex:&(showView->recognizeHilightIndex)];
            if(![attrInfo isEqualToString:@""]){
                showView->recognizeHilightLayerIndex = 1;
                layerTemp = (Layer *)[showView->map->layerData objectAtIndex:1];
                //获取国家信息
                str = [[layerTemp->dbfLayer->attrData objectAtIndex:showView->recognizeHilightIndex] objectAtIndex:1];
                
            }else{
                showView->recognizeHilightLayerIndex = 0;
                attrInfo = [self getAttrInfoByLayer:(Layer *)map->layerData  withLayerIndex:0 withAttrIndex:4 withLon:lon andLat:lat andOutputPolygonIndex:&(showView->recognizeHilightIndex)];
                if(![attrInfo isEqualToString:@""]){
                    layerTemp = (Layer *)[showView->map->layerData objectAtIndex:0];
                    //获取首都信息
                    str = [[layerTemp->dbfLayer->attrData objectAtIndex:showView->recognizeHilightIndex] objectAtIndex:3];
                }
            }
            location.text = [NSString stringWithFormat:@"经度:%.2f 纬度:%.2f",lon,lat];
            position.text = [NSString stringWithFormat:@"%@ -- %@",attrInfo,str];
        }
        
    }else if(showView->projectionPattern == MercatroProjectionPattern){
        NSLog(@".......Click....loc: X:%f and Y:%f",point.x,point.y);
        if(showView->mapDispalyType == ChinaMap){
            //ChinaMap--Mercator
            //clickPos 为quartz  2D coordinate  转换到quart 2D的坐标系
            clickPos = CGPointMake((point.x-showView.bounds.size.width/2)/showView->originScale,((point.y-showView.bounds.size.height/2)*(-1))/showView->originScale);
            double temp_x,temp_y;
            done = [showView->mercator_projection toProj:j2h((showView->extendBottom+showView->extendTop)/2) andL:j2h((showView->extendLeft+showView->extendRight)/2) andX:&temp_y andY:&temp_x];
            if(!done){
                clickPos.x += temp_x/showView->pScale;
                clickPos.y += temp_y/showView->pScale;
            }
            clickPos.x *= showView->pScale;
            clickPos.y *= showView->pScale;
            
            done = [showView->mercator_projection FromProj:clickPos.y andY:clickPos.x andB:&lat andL:&lon];
            if(!done){
                lon = h2j(lon);
                lat = h2j(lat);
                attrInfo = [self getAttrInfoByLayer:(Layer *)map->layerData  withLayerIndex:1 withAttrIndex:0 withLon:lon andLat:lat andOutputPolygonIndex:&(showView->recognizeHilightIndex)];
                showView->recognizeHilightLayerIndex = 1;
                if([attrInfo isEqualToString:@""]){
                    showView->recognizeHilightLayerIndex = 0;
                    attrInfo = [self getAttrInfoByLayer:(Layer *)map->layerData  withLayerIndex:0 withAttrIndex:0 withLon:lon andLat:lat andOutputPolygonIndex:&(showView->recognizeHilightIndex)];
                }
            }
            
            location.text = [NSString stringWithFormat:@"经度:%.2f 纬度:%.2f",lon,lat];
            position.text = [NSString stringWithFormat:@"%@",attrInfo];
        }else{
            //WorldMap--Mercator
            //clickPos 为quartz  2D coordinate  转换到quart 2D的坐标系
            clickPos = CGPointMake((point.x-showView.bounds.size.width/2)/showView->originScale,((point.y-showView.bounds.size.height/2)*(-1))/showView->originScale);
            clickPos.x = (clickPos.x * showView->pScale);
            clickPos.y = (clickPos.y * showView->pScale);
            
            done = [showView->mercator_projection FromProj:clickPos.y andY:clickPos.x andB:&lat andL:&lon];
            if(!done){
                lon = h2j(lon);
                lat = h2j(lat);
                
                attrInfo = [self getAttrInfoByLayer:(Layer *)map->layerData  withLayerIndex:1 withAttrIndex:0 withLon:lon andLat:lat andOutputPolygonIndex:&(showView->recognizeHilightIndex)];
                if(![attrInfo isEqualToString:@""]){
                    showView->recognizeHilightLayerIndex = 1;
                    layerTemp = (Layer *)[showView->map->layerData objectAtIndex:1];
                    //获取国家信息
                    str = [[layerTemp->dbfLayer->attrData objectAtIndex:showView->recognizeHilightIndex] objectAtIndex:1];
                    
                }else{
                    showView->recognizeHilightLayerIndex = 0;
                    attrInfo = [self getAttrInfoByLayer:(Layer *)map->layerData  withLayerIndex:0 withAttrIndex:4 withLon:lon andLat:lat andOutputPolygonIndex:&(showView->recognizeHilightIndex)];
                    if(![attrInfo isEqualToString:@""]){
                        layerTemp = (Layer *)[showView->map->layerData objectAtIndex:0];
                        //获取首都信息
                        str = [[layerTemp->dbfLayer->attrData objectAtIndex:showView->recognizeHilightIndex] objectAtIndex:3];
                    }
                }
            }
            
            location.text = [NSString stringWithFormat:@"经度:%.2f 纬度:%.2f",lon,lat];
            position.text = [NSString stringWithFormat:@"%@ -- %@",attrInfo,str];
        }
    }
    


    //测距
    if([measureSwitch isOn]){
        //绘点
        if(showView->util->isFirstTap == NO){
            showView->util->begin_point = point;
            showView->util->_lon1 = lon;
            showView->util->_lat1 = lat;
            showView->util->isFirstTap = YES;
            NSLog(@"begin:%f and %f",point.x,point.y);
            distanceLabel.text = [NSString stringWithFormat:@"直线距离:%dkm",0];
        }else{
            showView->util->end_point = point;
            showView->util->_lon2 = lon;
            showView->util->_lat2 = lat;
            showView->util->isFirstTap = NO;
            NSLog(@"end:%f and %f",point.x,point.y);
            
            double distance = [showView->util getDistance];
            NSLog(@"distance:%f",distance);
            distanceLabel.text = [NSString stringWithFormat:@"直线距离:%.2fkm",distance];
            
            position.text = [NSString stringWithFormat:@"%@ - %@",strTemp,attrInfo ];
        }
    }
    
    //记录上一次点击的位置
    strTemp = attrInfo;
    [showView setNeedsDisplay];
    NSLog(@"Tap-----End");

}

// 缩放手势
// 此方法在缩放过程中会被调用多次1
-(void)scaleGestureRecognizerHandle:(id)recognizer  {
    UIPinchGestureRecognizer *recognizerTemp = (UIPinchGestureRecognizer*)recognizer;
    
    // 很重要的一个属性scale，会被捕获到缩放的倍数
    // 参数一：原来的transform
    // 参数二：水平方向缩放的倍数
    // 参数三：垂直方向缩放的倍数
    // CGAffineTansform 仿射变换矩阵（矩阵中放置view的缩放倍数，旋转角度，x,y坐标等参数）
    // 将x,y方向的缩放倍数传给transform
//    recognizerTemp.view.transform = CGAffineTransformScale(recognizerTemp.view.transform, recognizerTemp.scale, recognizerTemp.scale);
//    // 会被多次调用这个方法，所以每次都要重置缩放倍数为原始倍数
//    recognizerTemp.scale = 1.0f;
    
    //第一个参数是相当于当前的状态
    recognizerTemp.view.transform = CGAffineTransformScale(recognizerTemp.view.transform, recognizerTemp.scale, recognizerTemp.scale);
    recognizerTemp.scale = 1;
    if ([recognizer state] == UIGestureRecognizerStateEnded) {
        NSLog(@"transform %f",recognizerTemp.view.transform.a);
        //showView->originScale = showView->originScale * recognizerTemp.view.transform.a;
        //[showView setNeedsDisplay];
    }

}

//drag
-(void)dragGestureRecognizerHandle:(UIPanGestureRecognizer*)recognizer  { 
    
    
    CGPoint p = [recognizer translationInView:showView];
    recognizer.view.transform = CGAffineTransformTranslate(recognizer.view.transform, p.x, p.y);
    [recognizer setTranslation:CGPointZero inView:showView];
    
    NSLog(@"paned");
    NSLog(@"point x:%d,y:%d",(int)p.x,(int)p.y);
    NSLog(@"center:x:%f and y:%f",recognizer.view.center.x ,recognizer.view.center.y);
}

//rotation
-(void)rotationGestureRecognizerHandle:(UIRotationGestureRecognizer*)recognizer  {
    
    /** 旋转 */
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;

}

#pragma mark- switchAction
-(void)switchAction:(id)sender{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        showView->isMeasuring = YES;
        [distanceLabel setHidden:NO];
    }else {
        showView->isMeasuring = NO;
        [distanceLabel setHidden:YES];
    }
    [showView setNeedsDisplay];
}

#pragma mark - QCheckBoxDelegate

- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked {
    NSLog(@"did tap on CheckBox:%@ checked:%d", checkbox.titleLabel.text, checked);
    
    long tag = checkbox.tag;
    if(tag == RecognizeCheckedTag){
        //识别选中区域
        if(checked){
            showView->recognizeHilightChecked = YES;
        }else{
            showView->recognizeHilightChecked = NO;
        }
    }else if(tag == AttrCheckedTag){
        //属性显示
        if(checked){
            showView->AttrDisplayChecked = YES;
        }else{
            showView->AttrDisplayChecked = NO;
        }
    }
    
    //show
    if([map->layerData count] != 0 && tag+1 <= [map->layerData count] && tag < RecognizeCheckedTag){
        Layer *layerTemp = (Layer *)[map->layerData objectAtIndex:tag];
        layerTemp->isShow = checked;
    }
    
    //update layers count label
    showlayersCountLabel.text = [NSString stringWithFormat:@"Layers : %d",[map getShowingLayersCount]];
    
    [showView setNeedsDisplay];

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //创建正则表达式，判断是否为英文
    NSString *regex = @"^[a-zA-Z]*$";
    NSString *regexChinese = @"^[\u4e00-\u9fa5]*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    NSPredicate *predicateChinese = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexChinese];
    
    NSArray *loc;
    double oneNumber;
    double twoNumber;
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        //获取输入框内的内容
        UITextField *LocField = [alertView textFieldAtIndex:0];
        NSLog(@"LOC : %@ ",LocField.text);
        //搜索位置，并高亮显示
        NSString *searchCondition = LocField.text;
        //去掉前后的空格
        searchCondition = [searchCondition stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        searchCondition = [SearchHelper convert:searchCondition];
        //如果全部为英文字符
        if([predicate evaluateWithObject:searchCondition]){
            NSLog(@"English");
            //英文无空格
        }
        
        if([predicateChinese evaluateWithObject:searchCondition]){
            NSLog(@"Chinese");
            //中文无空格   搜索中文
            int LayerInnerIndex;
            Layer *layerTemp;
            showView->isSearching = YES;

            for(int i=0;i<2;i++){
                layerTemp = [showView->map->layerData objectAtIndex:i];
                if(showView->mapDispalyType == ChinaMap){
                    //搜索中文
                    if([self getIndex:layerTemp andLayerInnerIndex:&LayerInnerIndex andColumeIndex:0 andSearchCondition:searchCondition])
                    {
                        showView->recognizeHilightLayerIndex = i;
                        showView->recognizeHilightIndex = LayerInnerIndex;
                        searchResultDisplay.text = [NSString stringWithFormat:@"搜索结果:%@",searchCondition];
                        break;
                    }else{
                        searchResultDisplay.text = [NSString stringWithFormat:@"搜索结果:%@",@"未搜到目标"];
                    }
                }else{
                    if(layerTemp->shpsLayer->shapefileType == ShapefileTypePoint){
                        if([self getIndex:layerTemp andLayerInnerIndex:&LayerInnerIndex andColumeIndex:0 andSearchCondition:searchCondition])
                        {
                            showView->recognizeHilightLayerIndex = i;
                            showView->recognizeHilightIndex = LayerInnerIndex;
                            searchResultDisplay.text = [NSString stringWithFormat:@"搜索结果:%@",searchCondition];
                            break;
                        }else{
                            searchResultDisplay.text = [NSString stringWithFormat:@"搜索结果:%@",@"未搜到目标"];
                        }
                    }else{
                        if([self getIndex:layerTemp andLayerInnerIndex:&LayerInnerIndex andColumeIndex:4 andSearchCondition:searchCondition])
                        {
                            showView->recognizeHilightLayerIndex = i;
                            showView->recognizeHilightIndex = LayerInnerIndex;
                            searchResultDisplay.text = [NSString stringWithFormat:@"搜索结果:%@",searchCondition];
                            break;
                        }else{
                            searchResultDisplay.text = [NSString stringWithFormat:@"搜索结果:%@",@"未搜到目标"];
                        }
                    }
                }
            }
            showView->searchResult = searchCondition;
            [showView setNeedsDisplay];
            return;
        }
        
        
        //第一个元素是纬度，第二个元素是经度
        if([searchCondition containsString:@","]){
            loc = [searchCondition componentsSeparatedByString:@","];
        }else if([searchCondition containsString:@" "]){
            //中间包含空格
            loc = [searchCondition componentsSeparatedByString:@" "];
        }
        
        if(loc != nil && loc.count>0){
            //纬度
            oneNumber = [(NSString *)[loc objectAtIndex:0] doubleValue];
            //经度
            twoNumber = [(NSString *)[loc objectAtIndex:1] doubleValue];
            //搜索经纬度
            showView->isSearching = YES;
            showView->searchResult = loc;
            if(oneNumber > 90 || oneNumber <-90 || twoNumber > 180 || twoNumber < -180){
                searchResultDisplay.text = [NSString stringWithFormat:@"搜索的%@越界",searchCondition];
            }else{
                searchResultDisplay.text = [NSString stringWithFormat:@"搜索结果:%@",searchCondition];
            }
            [showView setNeedsDisplay];
        }
    }
}

#pragma mark- projectionCenterCommboxAction
- (void)showMenu:(UIButton *)sender
{
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"请选择投影中心"
                     image:nil
                    target:nil
                    action:NULL],
      
      [KxMenuItem menuItem:@"北京"
                     image:[UIImage imageNamed:@"China"]
                    target:self
                    action:@selector(chooseProjCenterItem:)],    //点击菜单项处理事件
      
      [KxMenuItem menuItem:@"西安"
                     image:[UIImage imageNamed:@"China"]
                    target:self
                    action:@selector(chooseProjCenterItem:)],
      
      [KxMenuItem menuItem:@"伦敦"
                     image:[UIImage imageNamed:@"uk"]
                    target:self
                    action:@selector(chooseProjCenterItem:)],
      [KxMenuItem menuItem:@"纽约"
                     image:[UIImage imageNamed:@"us"]
                    target:self
                    action:@selector(chooseProjCenterItem:)],
      [KxMenuItem menuItem:@"巴西利亚"
                     image:[UIImage imageNamed:@"brazil"]
                    target:self
                    action:@selector(chooseProjCenterItem:)],
      [KxMenuItem menuItem:@"开罗"
                     image:[UIImage imageNamed:@"egypt"]
                    target:self
                    action:@selector(chooseProjCenterItem:)],
      [KxMenuItem menuItem:@"堪培拉"
                     image:[UIImage imageNamed:@"Australia"]
                    target:self
                    action:@selector(chooseProjCenterItem:)],
      [KxMenuItem menuItem:@"夏威夷"
                     image:[UIImage imageNamed:@"us"]
                    target:self
                    action:@selector(chooseProjCenterItem:)],
      [KxMenuItem menuItem:@"努克"
                     image:[UIImage imageNamed:@"nuke"]
                    target:self
                    action:@selector(chooseProjCenterItem:)],
      [KxMenuItem menuItem:@"南极洲"
                     image:nil
                    target:self
                    action:@selector(chooseProjCenterItem:)],

      ];
    KxMenuItem *first = menuItems[0];
    first.foreColor = [self infoBlueColor];  //设置菜单项的foreColor字体颜色，前背景颜色
    first.alignment = NSTextAlignmentCenter;   //设置菜单项的对其方式
    [KxMenu showMenuInView:self.view
                  fromRect:sender.frame
                 menuItems:menuItems];
}

#pragma mark-chooseProjectionPattern
- (void)chooseProj:(UIButton *)sender
{
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"请选择投影方式"
                     image:nil
                    target:nil
                    action:NULL],
      
      [KxMenuItem menuItem:@"无投影"
                     image:[UIImage imageNamed:@"noProj"]
                    target:self
                    action:@selector(chooseProjItem:)],    //点击菜单项处理事件
      
      [KxMenuItem menuItem:@"方位正射投影"
                     image:[UIImage imageNamed:@"orithProj"]
                    target:self
                    action:@selector(chooseProjItem:)],
      
      [KxMenuItem menuItem:@"Mercator投影"
                     image:[UIImage imageNamed:@"mercatorproj"]
                    target:self
                    action:@selector(chooseProjItem:)],
      ];
    
    KxMenuItem *first = menuItems[0];
    first.foreColor = [self infoBlueColor];  //设置菜单项的foreColor字体颜色，前背景颜色
    first.alignment = NSTextAlignmentCenter;   //设置菜单项的对其方式
    
    [KxMenu showMenuInView:self.view
                  fromRect:sender.frame
                 menuItems:menuItems];
}

#pragma mark-openCommboxAction
- (void)openMenu:(UIButton *)sender
{
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"请选择地图"
                     image:nil
                    target:nil
                    action:NULL],
      
      [KxMenuItem menuItem:@"ChinaMap"
                     image:[UIImage imageNamed:@"openChina"]
                    target:self
                    action:@selector(chooseMapItem:)],    //点击菜单项处理事件
      
      
      [KxMenuItem menuItem:@"WorldMap"
                     image:[UIImage imageNamed:@"openWorld"]
                    target:self
                    action:@selector(chooseMapItem:)],
      ];
    
    KxMenuItem *first = menuItems[0];
    first.foreColor = [self infoBlueColor];  //设置菜单项的foreColor字体颜色，前背景颜色
    first.alignment = NSTextAlignmentCenter;   //设置菜单项的对其方式
    
    [KxMenu showMenuInView:self.view
                  fromRect:sender.frame
                 menuItems:menuItems];
}

-(UIColor *)infoBlueColor
{
    return [UIColor colorWithRed:225/255.0f green:225/255.0f blue:0/255.0f alpha:1.0];
}

#pragma mark- 选定Map
- (void) chooseMapItem:(id)sender
{
    NSString *shpFileName;
    int layerIndex = 0;
    [self reset];
    //清理数据
    position.text = @"";
    [map->layerData removeAllObjects];
    [map displayLayers:[map->layerDisplayButton count] andHidden:YES];
    //设置所有图层
    [map setLayerButtonAllChecked:YES];
    KxMenuItem *item = (KxMenuItem *)sender;
    NSString *title = [item.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    

    
    if([title isEqualToString:@"ChinaMap"]){
        
        [location setHidden:NO];
        [distanceLabel setHidden:NO];
        [measureSwitch setEnabled:YES];
        
        showView->recognizeHilightIndex = -1;
        showView->projectionPattern = TwoDimentionsProjectionPattern;
        showView->mapDispalyType = ChinaMap;
        showView->pScale = TwoDInitScale;
        showView->mapDispalyType = ChinaMap;
        //先从指定位置加载
        shpFileName = @"shengjie";
        NSString *captical_strFileNameWithPath = [ShpHelper getFilePath:shpFileName];
        [map updateLayerName:layerIndex++ andName:shpFileName];
        
        Layer *shpLayer = [[Layer alloc] init];
        
        shpLayer->shpsLayer = [self openShapefile:[captical_strFileNameWithPath stringByAppendingString:@".shp"]];
        shpLayer->dbfLayer = [self openDbffile:[captical_strFileNameWithPath stringByAppendingString:@".dbf"]];
        shpLayer->shpsLayer->shp_shxFile = [self openShxfile:[captical_strFileNameWithPath stringByAppendingString:@".shx"]];
        
        
//        for(int i=0;i<[shpLayer->shpsLayer->m_objList count];i++){
//            ShapePolyline *sp = (ShapePolyline *)[shpLayer->shpsLayer->m_objList objectAtIndex:i];
//            
//            if([self cantains:sp andLon:96 andLat:35]){
//                NSLog(@"cantains %d",i);
//            }
//        }
        
        Layer *shpLayer_shenghui = [[Layer alloc] init];
        //打开省会文件
        shpFileName = @"shenghui";
        captical_strFileNameWithPath = [ShpHelper getFilePath:shpFileName];
        [map updateLayerName:layerIndex++ andName:shpFileName];

        shpLayer_shenghui->shpsLayer = [self openShapefile:[captical_strFileNameWithPath stringByAppendingString:@".shp"]];
        shpLayer_shenghui->dbfLayer = [self openDbffile:[captical_strFileNameWithPath stringByAppendingString:@".dbf"]];
        shpLayer_shenghui->shpsLayer->shp_shxFile = [self openShxfile:[captical_strFileNameWithPath stringByAppendingString:@".shx"]];
        
        //添加图层
        [map->layerData addObject:shpLayer];
        [map->layerData addObject:shpLayer_shenghui];
        

        
        [map displayLayers:map->layerData.count andHidden:NO];
        
    }else if([title isEqualToString:@"WorldMap"]){
        [measureSwitch setEnabled:YES];
        [location setHidden:NO];
        [distanceLabel setHidden:NO];
        showView->recognizeHilightIndex = -1;
        showView->projectionPattern = MercatroProjectionPattern;
        showView->mapDispalyType = WorldMap;
        shpFileName = @"Countries";
        NSString *targetPath1 = [ShpHelper getFilePath:shpFileName];
        [map updateLayerName:layerIndex++ andName:shpFileName];
        shpFileName = @"Capitals";
        NSString *targetPath2 = [ShpHelper getFilePath:shpFileName];
        [map updateLayerName:layerIndex++ andName:shpFileName];
        shpFileName = @"Grids";
        NSString *targetPath3 = [ShpHelper getFilePath:shpFileName];
        [map updateLayerName:layerIndex++ andName:shpFileName];
        shpFileName = @"Rivers";
        NSString *targetPath4 = [ShpHelper getFilePath:shpFileName];
        [map updateLayerName:layerIndex++ andName:shpFileName];
        shpFileName = @"Lakes";
        NSString *targetPath5 = [ShpHelper getFilePath:shpFileName];
        [map updateLayerName:layerIndex++ andName:shpFileName];
        shpFileName = @"ContinentBoundary";
        NSString *targetPath6 = [ShpHelper getFilePath:shpFileName];
        [map updateLayerName:layerIndex++ andName:shpFileName];
        shpFileName = @"CountryBoundary";
        NSString *targetPath7 = [ShpHelper getFilePath:shpFileName];
        [map updateLayerName:layerIndex++ andName:shpFileName];

        
        Layer *shpLayer1 = [[Layer alloc] init];
        
        shpLayer1->shpsLayer = [self openShapefile:[targetPath1 stringByAppendingString:@".shp"]];
        shpLayer1->dbfLayer = [self openDbffile:[targetPath1 stringByAppendingString:@".dbf"]];
        shpLayer1->shpsLayer->shp_shxFile = [self openShxfile:[targetPath1 stringByAppendingString:@".shx"]];
        
        Layer *shpLayer2 = [[Layer alloc] init];
        
        shpLayer2->shpsLayer = [self openShapefile:[targetPath2 stringByAppendingString:@".shp"]];
        shpLayer2->dbfLayer = [self openDbffile:[targetPath2 stringByAppendingString:@".dbf"]];
        shpLayer2->shpsLayer->shp_shxFile = [self openShxfile:[targetPath2 stringByAppendingString:@".shx"]];
        
        
        Layer *shpLayer3 = [[Layer alloc] init];
        
        shpLayer3->shpsLayer = [self openShapefile:[targetPath3 stringByAppendingString:@".shp"]];
        shpLayer3->dbfLayer = [self openDbffile:[targetPath3 stringByAppendingString:@".dbf"]];
        shpLayer3->shpsLayer->shp_shxFile = [self openShxfile:[targetPath3 stringByAppendingString:@".shx"]];
        
        Layer *shpLayer4 = [[Layer alloc] init];
        
        shpLayer4->shpsLayer = [self openShapefile:[targetPath4 stringByAppendingString:@".shp"]];
        shpLayer4->dbfLayer = [self openDbffile:[targetPath4 stringByAppendingString:@".dbf"]];
        shpLayer4->shpsLayer->shp_shxFile = [self openShxfile:[targetPath4 stringByAppendingString:@".shx"]];
        
        Layer *shpLayer5 = [[Layer alloc] init];
        
        shpLayer5->shpsLayer = [self openShapefile:[targetPath5 stringByAppendingString:@".shp"]];
        shpLayer5->dbfLayer = [self openDbffile:[targetPath5 stringByAppendingString:@".dbf"]];
        shpLayer5->shpsLayer->shp_shxFile = [self openShxfile:[targetPath5 stringByAppendingString:@".shx"]];
        
        Layer *shpLayer6 = [[Layer alloc] init];
        
        shpLayer6->shpsLayer = [self openShapefile:[targetPath6 stringByAppendingString:@".shp"]];
        shpLayer6->dbfLayer = [self openDbffile:[targetPath6 stringByAppendingString:@".dbf"]];
        shpLayer6->shpsLayer->shp_shxFile = [self openShxfile:[targetPath6 stringByAppendingString:@".shx"]];
        
        Layer *shpLayer7 = [[Layer alloc] init];
        
        shpLayer7->shpsLayer = [self openShapefile:[targetPath7 stringByAppendingString:@".shp"]];
        shpLayer7->dbfLayer = [self openDbffile:[targetPath7 stringByAppendingString:@".dbf"]];
        shpLayer7->shpsLayer->shp_shxFile = [self openShxfile:[targetPath7 stringByAppendingString:@".shx"]];
        

        
        
        
        //添加图层
        
        [map->layerData addObject:shpLayer1];
        [map->layerData addObject:shpLayer2];
        [map->layerData addObject:shpLayer3];
        [map->layerData addObject:shpLayer4];
        [map->layerData addObject:shpLayer5];
        [map->layerData addObject:shpLayer6];
        [map->layerData addObject:shpLayer7];

        [map displayLayers:map->layerData.count andHidden:NO];
    }
//    NSLog(@"%@",item.title);
//    NSLog(@"%@", sender);
    
    showView->map = map;
    Layer *baseLayer = (Layer *)[map->layerData objectAtIndex:0];
    Shapefile *baseShp = baseLayer->shpsLayer;
    showView->extendLeft = [baseShp extendLeft];
    showView->extendBottom = [baseShp extendBottom];
    showView->extendRight = [baseShp extendRight];
    showView->extendTop = [baseShp extendTop];
    
    
    showlayersCountLabel.text = [NSString stringWithFormat:@"Layers : %d",[map getShowingLayersCount]];
    [showView setNeedsDisplay];
}

#pragma mark-选定某一个投影方式
- (void) chooseProjItem:(id)sender
{
    KxMenuItem *item = (KxMenuItem *)sender;
    NSString *title = [item.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if([title isEqualToString:@"无投影"]){
        if(showView->mapDispalyType == WorldMap){
            return;
        }
        showView->projectionPattern = TwoDimentionsProjectionPattern;
        showView->pScale = TwoDInitScale;
    }else if([title isEqualToString:@"方位正射投影"]){
        NSLog(@"title%@",title);
        showView->projectionPattern = OrthographicProjectionPattern;
        if(showView->mapDispalyType == ChinaMap){
            showView->pScale = OPChina;
        }else{
            showView->pScale = OPWorld;
        }

        NSArray *projectionCenterTemp = [orthographic_projectionHelper getProjectionCenter:@"西安"];
        //设置西安为投影中心
        [showView->orthographic_projection set_center:j2h([(NSString *)[projectionCenterTemp objectAtIndex:0] doubleValue])  andLongitude:j2h([(NSString *)[projectionCenterTemp objectAtIndex:1] doubleValue])];
        //showView
    }else{
        showView->projectionPattern = MercatroProjectionPattern;
        showView->pScale = MPChina;
    }
    [showView setNeedsDisplay];
}

#pragma mark-选定城市作为投影中心
- (void) chooseProjCenterItem:(id)sender
{
    KxMenuItem *item = (KxMenuItem *)sender;
    NSString *title = [item.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *projectionCenterTemp = [orthographic_projectionHelper getProjectionCenter:title];
    [showView->orthographic_projection set_center:j2h([(NSNumber *)[projectionCenterTemp objectAtIndex:0] doubleValue]) andLongitude:j2h([(NSNumber *)[projectionCenterTemp objectAtIndex:1] doubleValue])];
    NSLog(@"%@",item.title);
    NSLog(@"%@", sender);
    [showView setNeedsDisplay];
}



#pragma mark- UIGestureRegognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return ![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && ![gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]];
}


//ALon 经度  ALat 纬度
-(BOOL)cantains:(ShapePolyline *)polyline andLon:(double)ALon andLat:(double)ALat{
    if(ALon < polyline->m_nBoundingBox[0] || ALon > polyline->m_nBoundingBox[2]
       || ALat < polyline->m_nBoundingBox[1] || ALat > polyline->m_nBoundingBox[3]){
        return NO;
    }
    ShapePoint *temp;
    int iSum = 0, iCount;
    double dLon1, dLon2, dLat1, dLat2, dLon;
    if ([polyline->m_Points count] < 3)
        return NO;
    iCount = (int)[polyline->m_Points count];

    double nPartsCount = [polyline->m_Parts count];
    double nPointsCount;
    int nStartPart,nEndPart;
    int j,k;
    //遍历polyline的所有parts
    for(j = 0; j < nPartsCount; j++)
    {
        nPointsCount = [polyline->m_Points count];
        
        NSNumber* startPart;
        startPart = [polyline->m_Parts objectAtIndex:j];
        nStartPart = [startPart intValue];
        
        if(j + 1 == nPartsCount)
            nEndPart = nPointsCount;
        else
        {
            NSNumber* endPart;
            endPart = [polyline->m_Parts objectAtIndex:j + 1];
            nEndPart = [endPart intValue];
        }
        
        //遍历一个parts的所有点
        for(k = nStartPart; k < nEndPart-PointRange; k=k+PointRange)
        {
            if (k == nEndPart - PointRange)
            {
                temp = (ShapePoint *)[polyline->m_Points objectAtIndex:k];
                dLon1 = temp->m_nEast;
                dLat1 = temp->m_nNorth;
                temp = (ShapePoint *)[polyline->m_Points objectAtIndex:0];
                dLon2 = temp->m_nEast;
                dLat2 = temp->m_nNorth;
            }
            else
            {
                temp = (ShapePoint *)[polyline->m_Points objectAtIndex:k];
                dLon1 = temp->m_nEast;
                dLat1 = temp->m_nNorth;
                temp = (ShapePoint *)[polyline->m_Points objectAtIndex:k+PointRange];
                dLon2 = temp->m_nEast;
                dLat2 = temp->m_nNorth;
            }
            if(fabs(dLat1-dLat2) > 1.5 || fabs(dLon1-dLon2) > 1.5){
                continue;
            }
            //以下语句判断A点是否在边的两端点的水平平行线之间，在则可能有交点，开始判断交点是否在左射线上
            if (((ALat >= dLat1) && (ALat < dLat2)) || ((ALat >= dLat2) && (ALat < dLat1)))
            {
                if (fabs(dLat1 - dLat2) > 0)
                {
                    //得到 A点向左射线与边的交点的x坐标：
                    dLon = dLon1 - ((dLon1 - dLon2) * (dLat1 - ALat)) / (dLat1 - dLat2);
                    // 如果交点在A点左侧（说明是做射线与 边的交点），则射线与边的全部交点数加一：
                    if (dLon < ALon)
                        iSum++;
                }
            }
        }
    }

    if (iSum % 2 != 0)
        return YES;
    return NO;
}

-(BOOL)cantainsPoint:(ShapePoint *)point andLon:(double)ALon andLat:(double)ALat{
    if(fabs(point->m_nNorth - ALat) <=[MapRenderer getPointRecognizedRadius:showView->mapDispalyType] && fabs(point->m_nEast - ALon) <=[MapRenderer getPointRecognizedRadius:showView->mapDispalyType]){
        return YES;
    }
    return NO;
}



-(int)getIndexInfoByLayer:(Layer *)layer withLon:(double)lon andLat:(double)lat{
    if(layer->shpsLayer->shapefileType == ShapefileTypePoint){
        for(int i=0;i<[layer->shpsLayer->m_objList count];i++){
            ShapePoint *sp = (ShapePoint *)[layer->shpsLayer->m_objList objectAtIndex:i];
            if([self cantainsPoint:sp andLon:lon andLat:lat]){
                NSLog(@"cantainsPoint %d",i);
                return i;
            }
        }
    }else if(layer->shpsLayer->shapefileType == ShapefileTypePolyLine || layer->shpsLayer->shapefileType == ShapefileTypePolygon){
        for(int i=0;i<[layer->shpsLayer->m_objList count];i++){
            ShapePolyline *sp = (ShapePolyline *)[layer->shpsLayer->m_objList objectAtIndex:i];
            if([self cantains:sp andLon:lon andLat:lat]){
                NSLog(@"cantains %d",i);
                return i;
            }
        }
    }
    return -1;
}

#pragma mark-依据中文搜索得到索引
-(BOOL)getIndex:(Layer *)_layer andLayerInnerIndex:(int *)innerIndex andColumeIndex:(int)columeIndex andSearchCondition:(NSString *)searchStr{
    NSString *attr;
    Shapefile *shapeFileTemp;
    Dbffile *DbfFileTemp;

    //取出图层

    shapeFileTemp = _layer->shpsLayer;
    DbfFileTemp = _layer->dbfLayer;
    //属性数据
    NSMutableArray *data = DbfFileTemp->attrData;
    NSMutableArray *rowData;
    //遍历dbfFile的属性信息
    for(int j=0;j<DbfFileTemp->recordCount;j++){
        rowData = [data objectAtIndex:j];
        attr = [rowData objectAtIndex:columeIndex];
        attr = [attr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        //如果属性为空就不添加
        if([[[ShpHelper alloc] init] isBlankString:attr]){
            continue;
        }
        //判断包含
        if([attr containsString:searchStr]){
            //赋值
            *innerIndex = j;
            return YES;
        }
    }
    return NO;
}

-(NSString *)getAttrInfoByLayer:(Layer *)layer withLayerIndex:(int)layerIndex withAttrIndex:(int)index withLon:(double)lon andLat:(double)lat andOutputPolygonIndex:(int *)indexInfo{
    Layer *layerTmep = [map->layerData objectAtIndex:layerIndex];
    *indexInfo = [self getIndexInfoByLayer:layerTmep withLon:lon andLat:lat];
    NSString *attrInfo;
    //判断是否点在了区域内
    if(*indexInfo != -1){
        attrInfo = [[layerTmep->dbfLayer->attrData objectAtIndex:*indexInfo] objectAtIndex:index];
        attrInfo = [attrInfo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }else{
        attrInfo = @"";
    }
    return attrInfo;
}



-(void)getBoundary:(double)b andLat:(double)l{
    

}

//判断是否为整形：

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

//判断是否为浮点形：

- (BOOL)isPureFloat:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}



@end

