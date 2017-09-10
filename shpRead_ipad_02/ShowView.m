//
//  ShowView.m
//  shpRead_ipad_02

//  show map info

//
//  Created by shy on 15/4/5.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import <CoreText/CoreText.h>
#import <math.h>
#import "ShowView.h"
#import "ViewController.h"
#import "Shxfile.h"
#import "Dbffile.h"
#import "MeasureUtil.h"
#import "ShpHelper.h"
#import "orthographic_projection_oc.h"
#import "Mercator_projection.h"
#import "Map.h"
#import "QCheckBox.h"
#import "MapRenderer.h"
#import "ViewHelper.h"






@implementation ShowView

@synthesize startPoint;
@synthesize zoom;
@synthesize load;


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

#pragma mark-drawRect
- (void)drawRect:(CGRect)rect {
    //标志哪个图层高亮
    BOOL hilightFlag = NO;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextSetLineWidth(context,[MapRenderer getLineWidth:drawdefault]);
    [[UIColor redColor] setStroke];
    
    if (mapDispalyType == ChinaMap) {
        
        if(projectionPattern == TwoDimentionsProjectionPattern){
            
            //CGContextTranslateCTM(context,offset.x, offset.y);
            CGContextTranslateCTM(context,viewHalfWidth + offset.x, viewHalfHeight + offset.y);
        }else if(projectionPattern == OrthographicProjectionPattern){
            CGContextTranslateCTM(context,viewHalfWidth + offset.x, viewHalfHeight + offset.y);
        }else{
            CGContextTranslateCTM(context,viewHalfWidth + offset.x, viewHalfHeight + offset.y);
        }
    }else{
        if(projectionPattern == OrthographicProjectionPattern){
            CGContextTranslateCTM(context,viewHalfWidth + offset.x, viewHalfHeight + offset.y);
        }else{
            CGContextTranslateCTM(context,viewHalfWidth + offset.x, viewHalfHeight + offset.y);
        }
    }
    
    


    

    
    CGContextScaleCTM(context,originScale, originScale);
    //旋转
    CGContextRotateCTM(context, angel);
    
    CGContextSaveGState(context);
    {

        //[self drawImage:CGPointMake(0, 0) andType:ImageTypeUnSearch andCGContext:context];
        //绘制坐标线
        [[UIColor blackColor] setStroke];
        CGContextAddEllipseInRect(context, CGRectMake(-5, -5, 10, 10));
        CGContextFillPath(context);

        Layer *shptemp;
        long nShapefileType;
        //取出所有图层
        for(int i=0;i<[map->layerData count];i++){
            
            shptemp = [map->layerData objectAtIndex:i];
            if(!shptemp->isShow){
                continue;
            }
            
            //设置每个图层的颜色为左侧标签的颜色
            [[(QCheckBox *)[map->layerDisplayButton objectAtIndex:i] titleColorForState:UIControlStateSelected] setFill];
            [[(QCheckBox *)[map->layerDisplayButton objectAtIndex:i] titleColorForState:UIControlStateSelected] setStroke];
            //取出每一个图层，绘制
            nShapefileType = [shptemp->shpsLayer shapefileType];
            
            //标志高亮的图层
            if(i == recognizeHilightLayerIndex){
                hilightFlag = YES;
            }else{
                hilightFlag = NO;
            }
            
            if(nShapefileType == ShapefileTypePoint){
                //[self drawShapePoint:shptemp->shpsLayer ];
                [self drawShapePoint:shptemp->shpsLayer andNeedsRecognizeHilight:recognizeHilightChecked&&hilightFlag andIndex:recognizeHilightIndex];
                //省会属性信息
                if (AttrDisplayChecked) {
                    [self drawAttrDbfInfo:shptemp->shpsLayer withDbf:shptemp->dbfLayer withIndex:0];
                }
            }
            if((nShapefileType == ShapefileTypePolyLine) || (nShapefileType == ShapefileTypePolygon)){
                NSDate *fir = [NSDate date];
                if(projectionPattern == TwoDimentionsProjectionPattern){
                    [self drawShapePolyline:shptemp->shpsLayer andDbfFile:shptemp->dbfLayer andNeedsRecognizeHilight:recognizeHilightChecked&&hilightFlag andIndex:recognizeHilightIndex];
                }else if(projectionPattern == OrthographicProjectionPattern){
                    [self drawShapePolylineOP:shptemp->shpsLayer andDbfFile:shptemp->dbfLayer andNeedsRecognizeHilight:recognizeHilightChecked&&hilightFlag andIndex:recognizeHilightIndex];
                }else{
                    [self drawShapePolylineOM:shptemp->shpsLayer andDbfFile:shptemp->dbfLayer andNeedsRecognizeHilight:recognizeHilightChecked&&hilightFlag andIndex:recognizeHilightIndex];
                }
                NSDate *sec = [NSDate date];
                NSLog(@"Time:%f",[sec timeIntervalSinceDate:fir]);
                //省名称属性信息
                if(AttrDisplayChecked && shptemp->dbfLayer != nil ){
                    if(projectionPattern == TwoDimentionsProjectionPattern){
                        [self drawAttrDbfInfo:shptemp->shpsLayer withDbf:shptemp->dbfLayer withIndex:0];
                    }else if(projectionPattern == OrthographicProjectionPattern){
                        //[self drawShapePolylineOP:shptemp->shpsLayer];
                        [self drawAttrDbfInfo:shptemp->shpsLayer withDbf:shptemp->dbfLayer withIndex:0];
                    }else{
                        [self drawAttrDbfInfo:shptemp->shpsLayer withDbf:shptemp->dbfLayer withIndex:0];
                    }
                }
            }
        }
    }
    
    if(isSearching){
        [self drawSearchResult:searchResult andContext:context];
    }
    
    //绘制坐标线
    [[UIColor blackColor] setStroke];
    CGContextMoveToPoint(context, 0, 400);
    CGContextAddLineToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 400, 0);
    CGContextStrokePath(context);
    CGContextAddEllipseInRect(context, CGRectMake(-5, -5, 10, 10));
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
    CGContextRestoreGState(context);
    //测距功能开启
    if(isMeasuring){
        if(self->util->isFirstTap ){
            [self drawImage:util->begin_point andType:ImageTypeUnLoc andCGContext:nil];
        }else{
            [self drawImage:util->begin_point andType:ImageTypeUnLoc andCGContext:nil];
            [self drawDistanceLine:util->begin_point andEndPoint:util->end_point];
            [self drawImage:util->end_point andType:ImageTypeUnLoc andCGContext:nil];
        }
    }else{
        [self drawImage:currentTap andType:ImageTypeUnLoc andCGContext:nil];
    }
    
}

-(void)setShapefile:(Shapefile *)shapefile{
    _m_shapefile = shapefile;
}


#pragma mark- drawShapePoint
-(void)drawShapePoint:(Shapefile *)shp andNeedsRecognizeHilight:(BOOL)flag andIndex:(int)index
{
    if(index < 0 || index >= [shp->m_objList count]){
        flag = NO;
    }
    
    BOOL done = 1;
    double x = 0,y = 0;
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置线宽
    CGContextSetLineWidth(context,[MapRenderer getLineWidth:drawPoint]);
    CGContextSaveGState(context);
    {
        long    i;
        long    nShapeCount;
        double    nEast, nNorth;
        nShapeCount = [shp->m_objList count];
        //设置点的半径
        
        double width = [MapRenderer getPointRadius];
        
        for(i = 0; i < nShapeCount; i++)
        {
            
            ShapePoint* shapePoint;
            shapePoint = [[ShapePoint alloc] init];
            shapePoint = [shp->m_objList objectAtIndex:i];
            
            nEast = shapePoint->m_nEast;
            nNorth = shapePoint->m_nNorth;
            
            if(mapDispalyType == ChinaMap){
                    //无投影
                if(projectionPattern == TwoDimentionsProjectionPattern){
                    pScale = TwoDInitScale;
                    x = (nEast - (extendLeft+extendRight)/2) * (pScale );
                    y = (nNorth - (extendBottom+extendTop)/2) * (pScale );
                    
                    //方位正射投影
                }else if(projectionPattern == OrthographicProjectionPattern){
                    pScale = OPChina;
                    done = [orthographic_projection transit_to_xy:&x andY:&y andLat:j2h(nNorth) andLon:j2h(nEast)];
                    if(!done){
                        continue;
                    }
                    x /= pScale;
                    y /= pScale;
                    
                    //Mercator投影
                }else if(projectionPattern == MercatroProjectionPattern){
                    pScale = MPChina;
                    done = [mercator_projection toProj:j2h(nNorth) andL:j2h(nEast) andX:&y andY:&x];
                    if(done == 1){
                        continue;
                    }
                    double tempx;
                    double tempy;
                    x /= pScale;
                    y /= pScale;
                    done = [mercator_projection toProj:j2h((extendBottom+extendTop)/2) andL:j2h((extendLeft+extendRight)/2) andX:&tempy andY:&tempx];
                    x -= tempx/pScale;
                    y -= tempy/pScale;
                }
            }else{
                if(projectionPattern == OrthographicProjectionPattern){
                    pScale = OPWorld;
                    NSLog(@"OPWorld");
                    done = [orthographic_projection transit_to_xy:&x andY:&y andLat:j2h(nNorth) andLon:j2h(nEast)];
                    if(!done){
                        continue;
                    }
                    x /= pScale;
                    y /= pScale;
                    //Mercator投影
                }else if(projectionPattern == MercatroProjectionPattern){
                    pScale = MPWorld;
                    done = [mercator_projection toProj:j2h(nNorth) andL:j2h(nEast) andX:&y andY:&x];
                    
                    if(done == 1){
                        continue;
                    }
                    x /= pScale;
                    y /= pScale;
                }
            }
            ////画一个椭圆 第一种方案
            if(flag && index == i){
                    //高亮绘制
                    [self drawCircle:CGPointMake(x-width/2, y-width/2) withColor:[UIColor colorWithRed:0 green:255 blue:255 alpha:1.0]];
            }else{
                //普通绘制（红色）
                [self drawCircle:CGPointMake(x-width/2, y-width/2) withColor:[UIColor redColor]];
            }

            //画一个椭圆  第二种方案
            //CGContextAddEllipseInRect(context, CGRectMake(x-width/2, y-width/2, width, width));
            //填充颜色
            //CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
        }
        //在context上绘制
        CGContextFillPath(context);
    }
    CGContextRestoreGState(context);
}

#pragma mark-drawPolyline
-(void)drawShapePolyline:(Shapefile *)shp andDbfFile:(Dbffile *)dbfFile andNeedsRecognizeHilight:(BOOL)flag andIndex:(int)index
{
    if(index < 0 || index >= [shp->m_objList count]){
        flag = NO;
    }
    
    long    i, j, k;
    long    nShapeCount;
    CGPoint ptToDraw;
    double    nEast, nNorth;
    long    nPartsCount;
    long    nPointsCount;
    long    nStartPart;
    long    nEndPart;
    
    pScale = TwoDInitScale;
    nShapeCount = [shp->m_objList count];
    CGContextRef context = UIGraphicsGetCurrentContext();

    //设置线宽
    CGContextSetLineWidth(context, [MapRenderer getLineWidth:drawPolyline]);
    //[[UIColor blackColor] setStroke];
    CGContextSaveGState(context);
    {
        for(i = 0; i < nShapeCount; i++)
        {
            ShapePolyline* shapePolyline;
            shapePolyline = [[ShapePolyline alloc] init];
            
            shapePolyline = [shp->m_objList objectAtIndex:i];
            nPartsCount = [shapePolyline->m_Parts count];
            
            //依据颜色码获取颜色
            if([[shp->m_strShapefile lastPathComponent] isEqualToString:@"shengjie_region.shp"]){
                NSString *shengjie_Id = [[dbfFile->attrData objectAtIndex:i] objectAtIndex:4];
                shengjie_Id = [shengjie_Id stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                //找shengjie_id字段（唯一标示）
                UIColor *color = [MapRenderer getColorByCode:[shengjie_Id intValue]];
                [color setFill];
            }
            BOOL tag = NO;
            if(flag){
                //需要高亮
                if(index == i){
                    tag = YES;
                    CGContextSaveGState(context);
                    [[UIColor colorWithRed:0 green:255 blue:255 alpha:1.0] setFill];
                    CGContextSetLineWidth(context, 1);
                }
            }
            

            for(j = 0; j < nPartsCount; j++)
            {
                nPointsCount = [shapePolyline->m_Points count];
                NSNumber* startPart;
                startPart = [shapePolyline->m_Parts objectAtIndex:j];
                nStartPart = [startPart intValue];
                if(j + 1 == nPartsCount)
                    nEndPart = nPointsCount;
                else
                {
                    NSNumber* endPart;
                    endPart = [shapePolyline->m_Parts objectAtIndex:j + 1];
                    nEndPart = [endPart intValue];
                }
                for(k = nStartPart; k < nEndPart; k++)
                {
                    ShapePoint* point = [[ShapePoint alloc] init];
                    point = [shapePolyline->m_Points objectAtIndex:k];
                    nEast = point->m_nEast;
                    nNorth = point->m_nNorth;
                    ptToDraw.x = (nEast - (extendLeft+extendRight)/2) * (pScale );
                    ptToDraw.y = (nNorth - (extendBottom+extendTop)/2) * (pScale );
                    if(k == nStartPart){
                        CGContextMoveToPoint(context, ptToDraw.x, ptToDraw.y);
                    }
                    else{
                        CGContextAddLineToPoint(context, ptToDraw.x, ptToDraw.y);
                    }
                }
                if(flag && tag){
                    CGContextFillPath(context);
                }else{
                    if([[shp->m_strShapefile lastPathComponent] isEqualToString:@"shengjie_region.shp"]){
                        CGContextFillPath(context);
                    }else{
                        CGContextStrokePath(context);
                    }
                }
            }
            tag = NO;
            if(flag){
                if(index == i){
                    CGContextRestoreGState(context);
                }
            }
        }
    }
    CGContextRestoreGState(context);
}

#pragma mark-drawShapePolylineOrthographicProjection
-(void)drawShapePolylineOP:(Shapefile *)shp andDbfFile:(Dbffile *)dbfFile andNeedsRecognizeHilight:(BOOL)flag andIndex:(int)index
{
    
    long    i, j, k;
    long    nShapeCount;
    //CGPoint ptToDraw;
    double    nEast, nNorth;
    long    nPartsCount;
    long    nPointsCount;
    long    nStartPart;
    long    nEndPart;
    double x,y;
    BOOL done;
    if(mapDispalyType == ChinaMap){
        pScale = OPChina;
    }else{
        pScale = OPWorld;
    }

    
    BOOL hasStartPointFlag = NO;
    //double nZoom = scale;
    nShapeCount = [shp->m_objList count];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //设置线宽
    CGContextSetLineWidth(context,[MapRenderer getLineWidth:drawPolygon]);
    CGContextSaveGState(context);
    {
        for(i = 0; i < nShapeCount; i++)
        {
            ShapePolyline* shapePolyline;
            shapePolyline = [[ShapePolyline alloc] init];
            
            shapePolyline = [shp->m_objList objectAtIndex:i];
            nPartsCount = [shapePolyline->m_Parts count];

            
            //依据颜色码获取颜色
            if(mapDispalyType == ChinaMap)
            if([[shp->m_strShapefile lastPathComponent] isEqualToString:@"shengjie_region.shp"]){
                NSString *shengjie_Id = [[dbfFile->attrData objectAtIndex:i] objectAtIndex:4];
                shengjie_Id = [shengjie_Id stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                //找shengjie_id字段（唯一标示）
                UIColor *color = [MapRenderer getColorByCode:[shengjie_Id intValue]];
                [color setFill];
            }
            
            //依据颜色码获取颜色
            if(mapDispalyType == WorldMap)
            if([[shp->m_strShapefile lastPathComponent] isEqualToString:@"Countries.shp"]){
                NSString *attrInfo = [[dbfFile->attrData objectAtIndex:i] objectAtIndex:2];
                attrInfo = [attrInfo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                UIColor *color = [MapRenderer getColorByNumber:[attrInfo intValue]];
                [color setFill];
            }
            BOOL tag = NO;
            if(flag){
                //需要高亮
                if(index == i){
                    tag = YES;
                    CGContextSaveGState(context);
                    [[UIColor colorWithRed:0 green:255 blue:255 alpha:1.0] setFill];
                    CGContextSetLineWidth(context, 1);
                }
            }
            
            for(j = 0; j < nPartsCount; j++)
            {
                nPointsCount = [shapePolyline->m_Points count];
                
                NSNumber* startPart;
                NSNumber* endPart;
                startPart = [shapePolyline->m_Parts objectAtIndex:j];
                nStartPart = [startPart intValue];
                
                if(j + 1 == nPartsCount)
                    nEndPart = nPointsCount;
                else
                {
                    endPart = [shapePolyline->m_Parts objectAtIndex:j + 1];
                    nEndPart = [endPart intValue];
                }
                
                for(k = nStartPart; k < nEndPart; k++)
                {
                    
                    ShapePoint* point = [[ShapePoint alloc] init];
                    point = [shapePolyline->m_Points objectAtIndex:k];
                    nEast = point->m_nEast;
                    nNorth = point->m_nNorth;
            
                    
                    done = [orthographic_projection transit_to_xy:&x andY:&y andLat:j2h(nNorth) andLon:j2h(nEast)];
                    if(!done){
                        hasStartPointFlag = NO;
                        continue;
                    }
                    x /= pScale;
                    y /= pScale;
                    
                    if(k == nStartPart){
                        hasStartPointFlag = YES;
                        CGContextMoveToPoint(context, x, y);
                    }
                    else{
                        if(hasStartPointFlag){
                            CGContextAddLineToPoint(context, x, y);
                        }else{
                            hasStartPointFlag = YES;
                            CGContextMoveToPoint(context, x, y);
                        }
                    }
                }
                hasStartPointFlag = NO;
                if(flag && tag){
                    CGContextFillPath(context);
                }else{
                    if(mapDispalyType == ChinaMap){
                        if([[shp->m_strShapefile lastPathComponent] isEqualToString:@"shengjie_region.shp"]){
                            CGContextFillPath(context);
                        }else{
                            CGContextStrokePath(context);
                        }
                    }
                    if(mapDispalyType == WorldMap){
                        if([[shp->m_strShapefile lastPathComponent] isEqualToString:@"Countries.shp"]){
                            CGContextFillPath(context);
                        }else{
                            CGContextStrokePath(context);
                        }
                    }
                }

            }
            tag = NO;
            if(flag){
                if(index == i){
                    CGContextRestoreGState(context);
                }
            }
        }
    }
    CGContextRestoreGState(context);
}


#pragma mark-drawShapePolylineMerCator
-(void)drawShapePolylineOM:(Shapefile *)shp andDbfFile:(Dbffile *)dbfFile andNeedsRecognizeHilight:(BOOL)flag andIndex:(int)index
{
    if(index < 0 || index >= [shp->m_objList count]){
        flag = NO;
    }
    long    i, j, k;
    long    nShapeCount;
    double    nEast, nNorth;
    long    nPartsCount;
    long    nPointsCount;
    long    nStartPart;
    long    nEndPart;
    double x = 0,y = 0;
    BOOL done = 1;
    
    BOOL hasStartPointFlag = NO;
    nShapeCount = [shp->m_objList count];
    [mercator_projection setAB:6378245 andB:6356863];
    [mercator_projection setB0:j2h(0)];
    [mercator_projection setL0:j2h(0)];

    if (mapDispalyType == ChinaMap) {
        pScale = MPChina;
    }else{
        pScale = MPWorld;
    }

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //设置线宽
    CGContextSetLineWidth(context, [MapRenderer getLineWidth:drawPolygon]);
    CGContextSaveGState(context);
    {
        for(i = 0; i < nShapeCount; i++)
        {
            ShapePolyline* shapePolyline;
            shapePolyline = [[ShapePolyline alloc] init];
            
            shapePolyline = [shp->m_objList objectAtIndex:i];
            nPartsCount = [shapePolyline->m_Parts count];
            
            
            //依据颜色码获取颜色
            if(mapDispalyType == ChinaMap)
                if([[shp->m_strShapefile lastPathComponent] isEqualToString:@"shengjie_region.shp"]){
                    NSString *shengjie_Id = [[dbfFile->attrData objectAtIndex:i] objectAtIndex:4];
                    shengjie_Id = [shengjie_Id stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    //找shengjie_id字段（唯一标示）
                    UIColor *color = [MapRenderer getColorByCode:[shengjie_Id intValue]];
                    [color setFill];
                }
            //依据颜色码获取颜色
            if(mapDispalyType == WorldMap)
            if([[shp->m_strShapefile lastPathComponent] isEqualToString:@"Countries.shp"]){
                NSString *attrInfo = [[dbfFile->attrData objectAtIndex:i] objectAtIndex:2];
                attrInfo = [attrInfo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                UIColor *color = [MapRenderer getColorByNumber:[attrInfo intValue]];
                [color setFill];
            }
            
            BOOL tag = NO;
            if(flag){
                //需要高亮
                if(index == i){
                    tag = YES;
                    CGContextSaveGState(context);
                    [[UIColor colorWithRed:0 green:255 blue:255 alpha:1.0] setFill];
                    CGContextSetLineWidth(context, 1);
                }
            }
    
            for(j = 0; j < nPartsCount; j++)
            {
                nPointsCount = [shapePolyline->m_Points count];
                NSNumber* startPart;
                NSNumber* endPart;
                startPart = [shapePolyline->m_Parts objectAtIndex:j];
                nStartPart = [startPart intValue];
                
                if(j + 1 == nPartsCount)
                    nEndPart = nPointsCount;
                else
                {
                    endPart = [shapePolyline->m_Parts objectAtIndex:j + 1];
                    nEndPart = [endPart intValue];
                }
                

                
                for(k = nStartPart; k < nEndPart; k++)
                {
                    
                    ShapePoint* point = [[ShapePoint alloc] init];
                    point = [shapePolyline->m_Points objectAtIndex:k];
                    nEast = point->m_nEast;
                    nNorth = point->m_nNorth;
                
                    done = [mercator_projection toProj:j2h(nNorth) andL:j2h(nEast) andX:&y andY:&x];

                    if(done == 1){
                        hasStartPointFlag = NO;
                        continue;
                    }
                    if(mapDispalyType == ChinaMap){
                        double tempx;
                        double tempy;
                        x /= pScale;
                        y /= pScale;
                        done = [mercator_projection toProj:j2h((extendBottom+extendTop)/2) andL:j2h((extendLeft+extendRight)/2) andX:&tempy andY:&tempx];
                        if(!done){
                            x -= tempx/pScale;
                            y -= tempy/pScale;
                        }

                    }else{
                        x /= pScale;
                        y /= pScale;
                    }

                    
                    //[self updateViewSize:x andHeight:y];
                    
                    if(k == nStartPart){
                        hasStartPointFlag = YES;
                        CGContextMoveToPoint(context, x, y);
                    }
                    else{
                        if(hasStartPointFlag){
                            CGContextAddLineToPoint(context, x, y);
                        }else{
                            hasStartPointFlag = YES;
                            CGContextMoveToPoint(context, x, y);
                        }
                    }
                }
                hasStartPointFlag = NO;
                if(flag && tag){
                    CGContextFillPath(context);
                }else{
                    if(mapDispalyType == ChinaMap){
                        if([[shp->m_strShapefile lastPathComponent] isEqualToString:@"shengjie_region.shp"]){
                            CGContextFillPath(context);
                        }else{
                            CGContextStrokePath(context);
                        }
                    }
                    if(mapDispalyType == WorldMap){
                        if([[shp->m_strShapefile lastPathComponent] isEqualToString:@"Countries.shp"]){
                            CGContextFillPath(context);
                        }else{
                            CGContextStrokePath(context);
                        }
                    }
                }
            }
            tag = NO;
            if(flag){
                if(index == i){
                    CGContextRestoreGState(context);
                }
            }
        }
    }
    CGContextRestoreGState(context);
}





#pragma mark-drawAttrDbfInfo
-(void)drawAttrDbfInfo:(Shapefile *)shp withDbf:(Dbffile *)dbf withIndex:(int)index{

    //下一列的数据，判断是否面积接近于0
    NSString *temp;
    BOOL done = 1;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    {
        long _shpType = shp->shapefileType;
        //绘制指定列的属性信息
        NSString *attr;
        //属性数据
        NSMutableArray *data = dbf->attrData;
        NSMutableArray *rowData;
        
        float nZoom = pScale;
        double tempX = 0,tempY = 0;

        
        ShapePoint *point_temp;
        ShapePolyline *polyline_temp;
        //多边形中间位置
        double polylineCenterLoc_X;
        double polylineCenterLoc_Y;
        
        //遍历dbfFile的属性信息
        for(int i=0;i<dbf->recordCount;i++){
            rowData = [data objectAtIndex:i];
            attr = [rowData objectAtIndex:index];
            attr = [attr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
            
            //如果属性为空就不添加
            if([[[ShpHelper alloc] init] isBlankString:attr]){
                continue;
            }
            
            temp = (NSString *)[dbf->colomuName objectAtIndex:index+1];

            if(shp->shapefileType == ShapefileTypePoint){
            
            }else{
                //如果面积过小就不绘制属性信息
                ShapePolyline *polylineTemp = (ShapePolyline *)[shp->m_objList objectAtIndex:i];
                if(fabs(polylineTemp->m_nBoundingBox[0]-polylineTemp->m_nBoundingBox[2]) < 2 && fabs(polylineTemp->m_nBoundingBox[1]-polylineTemp->m_nBoundingBox[3]) < 2){
                    continue;
                }
            }
            
            //创建AttributeString
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc]
                                                 initWithString:attr];
            //创建字体以及字体大小
            
            CTFontRef helvetica = CTFontCreateWithName(CFSTR("Helvetica"),[MapRenderer getFontSize:mapDispalyType], NULL);
            //        CTFontRef helveticaBold = CTFontCreateWithName(CFSTR("Helvetica-Bold"), 14.0, NULL);
            
            //添加字体 目标字符串从下标0开始到字符串结尾
            [string addAttribute:(id)kCTFontAttributeName
                           value:(__bridge id)helvetica
                           range:NSMakeRange(0, [string length])];
            //创建文本对齐方式
            CTTextAlignment alignment = kCTLeftTextAlignment;//左对齐kCTRightTextAlignment为右对齐
            CTParagraphStyleSetting alignmentStyle;
            alignmentStyle.spec=kCTParagraphStyleSpecifierAlignment;//指定为对齐属性
            alignmentStyle.valueSize=sizeof(alignment);
            alignmentStyle.value=&alignment;
            // layout master
            CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
            
            CGMutablePathRef leftColumnPath = CGPathCreateMutable();
            
            //将属性信息绘制到相应位置
            if(_shpType == ShapefileTypePoint){
                //绘制点类型的标签信息
                point_temp = [shp->m_objList objectAtIndex:i];
                
                if(projectionPattern == TwoDimentionsProjectionPattern){
                    //ChinaMap--Point--Default
                    tempX = (point_temp->m_nEast-(extendLeft+extendRight)/2)*(nZoom );
                    tempY = (point_temp->m_nNorth-(extendBottom+extendTop)/2)*(nZoom )*(-1)+self.bounds.size.height;
                }else if(projectionPattern == OrthographicProjectionPattern){
                    //WorldMap and ChinaMap--Point--OrthographicProjectionPattern
                        done = [orthographic_projection transit_to_xy:&tempX andY:&tempY andLat:j2h(point_temp->m_nNorth) andLon:j2h(point_temp->m_nEast)];
                        if(!done){
                            continue;
                        }
                        tempX /= pScale;
                        tempY /= pScale;
                        tempY = tempY*(-1)+self.bounds.size.height;
                }else if (projectionPattern == MercatroProjectionPattern){
                    if(mapDispalyType == ChinaMap){
                        done = [mercator_projection toProj:j2h(point_temp->m_nNorth) andL:j2h(point_temp->m_nEast) andX:&tempY andY:&tempX];
                        
                        if(done == 1){
                            continue;
                        }
                        tempX /= pScale;
                        tempY /= pScale;
                        double tempx;
                        double tempy;
                        done = [mercator_projection toProj:j2h((extendBottom+extendTop)/2) andL:j2h((extendLeft+extendRight)/2) andX:&tempy andY:&tempx];
                        tempX -= tempx/pScale;
                        tempY -= tempy/pScale;
                        tempY = tempY*(-1)+self.bounds.size.height;
                    }else{
                        done = [mercator_projection toProj:j2h(point_temp->m_nNorth) andL:j2h(point_temp->m_nEast) andX:&tempY andY:&tempX];
                        if(done == 1){
                            continue;
                        }
                        tempX /= pScale;
                        tempY /= pScale;
                        tempY = tempY*(-1)+self.bounds.size.height;
                    }
                }
                CGPathAddRect(leftColumnPath, NULL,
                              CGRectMake(tempX , -tempY,self.bounds.size.width,self.bounds.size.height));
                CTFrameRef leftFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, 0),leftColumnPath,NULL);
                // draw
                CTFrameDraw(leftFrame, context);
            }else if(_shpType == ShapefileTypePolyLine || _shpType == ShapefileTypePolygon){
                if(mapDispalyType == ChinaMap){
                    if(projectionPattern == TwoDimentionsProjectionPattern){
                        //ChinaMap--TwoDimentionsProjectionPattern
                        //绘制多边形的标签信息
                        polyline_temp = [shp->m_objList objectAtIndex:i];
                        //取边界的中点绘制，此处有待优化
                        polylineCenterLoc_X = (polyline_temp->m_nBoundingBox[0] + polyline_temp->m_nBoundingBox[2])/2;
                        polylineCenterLoc_Y = (polyline_temp->m_nBoundingBox[1] + polyline_temp->m_nBoundingBox[3])/2;
                        
                        
                        tempX = (polylineCenterLoc_X-(extendLeft+extendRight)/2)*(nZoom );
                        tempY = (polylineCenterLoc_Y-(extendBottom+extendTop)/2)*(nZoom )*(-1)+self.bounds.size.height;
                    }else if(projectionPattern == OrthographicProjectionPattern){
                        //ChinaMap--OrthographicProjectionPattern
                        polyline_temp = [shp->m_objList objectAtIndex:i];
                        //取边界的中点绘制，此处有待优化
                        polylineCenterLoc_X = (polyline_temp->m_nBoundingBox[0] + polyline_temp->m_nBoundingBox[2])/2;
                        polylineCenterLoc_Y = (polyline_temp->m_nBoundingBox[1] + polyline_temp->m_nBoundingBox[3])/2;
                        
                        done = [orthographic_projection transit_to_xy:&tempX andY:&tempY andLat:j2h(polylineCenterLoc_Y) andLon:j2h(polylineCenterLoc_X)];
                        if(!done){
                            continue;
                        }
                        tempX /= pScale;
                        tempY /= pScale;
                        tempY = tempY*(-1)+self.bounds.size.height;
                    }else{
                        //ChinaMap--MerCatorProj
                        polyline_temp = [shp->m_objList objectAtIndex:i];
                        //取边界的中点绘制，此处有待优化
                        polylineCenterLoc_X = (polyline_temp->m_nBoundingBox[0] + polyline_temp->m_nBoundingBox[2])/2;
                        polylineCenterLoc_Y = (polyline_temp->m_nBoundingBox[1] + polyline_temp->m_nBoundingBox[3])/2;
                        
                        done = [mercator_projection toProj:j2h(polylineCenterLoc_Y) andL:j2h(polylineCenterLoc_X) andX:&tempY andY:&tempX];
                        if(done == 1){
                            continue;
                        }
                        tempX /= pScale;
                        tempY /= pScale;
                        double tempx;
                        double tempy;
                        done = [mercator_projection toProj:j2h((extendBottom+extendTop)/2) andL:j2h((extendLeft+extendRight)/2) andX:&tempy andY:&tempx];
                        tempX -= tempx/pScale;
                        tempY -= tempy/pScale;
                        tempY = tempY*(-1)+self.bounds.size.height;
                    }
                }else{
                    //WorldMap--Or
                    if(projectionPattern == OrthographicProjectionPattern){
                        
                    }else{
                        //WorldMap--Mercator
                        //绘制多边形的标签信息
                        polyline_temp = [shp->m_objList objectAtIndex:i];
                        //取边界的中点绘制，此处有待优化
                        polylineCenterLoc_X = (polyline_temp->m_nBoundingBox[0] + polyline_temp->m_nBoundingBox[2])/2;
                        polylineCenterLoc_Y = (polyline_temp->m_nBoundingBox[1] + polyline_temp->m_nBoundingBox[3])/2;
                        
                        tempX = (polylineCenterLoc_X-extendLeft)*(nZoom );
                        tempY = (polylineCenterLoc_Y-extendBottom)*(nZoom )*(-1)+self.bounds.size.height;
                    }
                }

                
                
                CGPathAddRect(leftColumnPath, NULL,
                              CGRectMake(tempX , -tempY,self.bounds.size.width,self.bounds.size.height));
                
                CTFrameRef leftFrame = CTFramesetterCreateFrame(framesetter,
                                                                CFRangeMake(0, 0),
                                                                leftColumnPath, NULL);
                // draw
                CTFrameDraw(leftFrame, context);
                
            }
            // cleanup
            CGPathRelease(leftColumnPath);
            CFRelease(framesetter);
            CFRelease(helvetica);
        }
    }
    CGContextRestoreGState(context);
}

#pragma mark-drawDistanceLine
-(void)drawDistanceLine:(CGPoint)begin andEndPoint:(CGPoint)end{

    UIColor *color = [UIColor redColor];
    [color set]; //设置线条颜色
    
    UIBezierPath* aPath = [UIBezierPath bezierPath];
    aPath.lineWidth = [MapRenderer getLineWidth:drawDistance];
    
    //aPath.lineCapStyle = kCGLineCapRound; //线条拐角
    aPath.lineJoinStyle = kCGLineCapRound; //终点处理
    
    // Set the starting point of the shape.
    [aPath moveToPoint:begin];
    
    // Draw the lines
    [aPath addLineToPoint:end];
    
    [aPath stroke];//Draws line 根据坐标点连线
}

#pragma mark-drawDistanceLine
-(void)drawCircle:(CGPoint)point withColor:(UIColor *)color{
    double radius;
    [color set]; //设置线条颜色
    UIBezierPath* aPath = [UIBezierPath bezierPath];
    aPath.lineWidth = 2.0;
    if(projectionPattern == TwoDimentionsProjectionPattern){
        radius = 3;
    }else if(projectionPattern == OrthographicProjectionPattern){
        radius = 2;
    }else{
        radius = 2;
    }
    //aPath.lineCapStyle = kCGLineCapRound; //线条拐角
    aPath.lineJoinStyle = kCGLineCapRound; //终点处理
    [aPath addArcWithCenter:point radius:radius startAngle:0.0 endAngle:180.0 clockwise:YES];
    // Set the starting point of the shape.
    [aPath stroke];//Draws line 根据坐标点连线
}

#pragma mark-drawImage
-(void)drawImage:(CGPoint)point andType:(int)type andCGContext:(CGContextRef)context{
    NSString *imagePath;
    CGPoint p;
    UIImage *img;

    if(type == ImageTypeUnLoc){
        imagePath = [[NSBundle mainBundle] pathForResource:@"location" ofType:@"png"];
//        // 1.取得图片
//        img = [[UIImage alloc] initWithContentsOfFile:imagePath];
//        cgImage= [img CGImage];
//        p =  CGPointMake(point.x-[img size].width/2, point.y);
//        
//        CGContextDrawImage(context, CGRectMake(p.x, p.y, 40, 40), cgImage);
        
        
        img = [[UIImage alloc] initWithContentsOfFile:imagePath];
        p =  CGPointMake(point.x-[img size].width/2, point.y-[img size].height);
        [img drawAtPoint:p];
    }else if(type == ImageTypeUnSearch){
        imagePath = [[NSBundle mainBundle] pathForResource:@"dingwei" ofType:@"png"];
        img = [[UIImage alloc] initWithContentsOfFile:imagePath];
//        cgImage= [img CGImage];
//        p =  CGPointMake(point.x-[img size].width/2, point.y);
//        //p =  CGPointMake(point.x-[img size].width/2, point.y-[img size].height);
//        CGContextDrawImage(context, CGRectMake(p.x, p.y, 40, 40), cgImage);
        UIButton *btnTemp = [[UIButton alloc] initWithFrame:CGRectMake(point.x, point.y, 40, 40)];
        [btnTemp setImage:img forState:UIControlStateNormal];
        [self addSubview:btnTemp];

    }

    

    //记得释放
    if(cgImage != nil){
//        CGImageRelease(cgImage);
//        UIGraphicsEndImageContext();
    }
    
}

-(BOOL)drawSearchResult:(NSObject *)_searchResult andContext:(CGContextRef)context{
    double xTemp,yTemp;
    NSString *imagePath;
    UIImage *img;
    imagePath = [[NSBundle mainBundle] pathForResource:@"dingwei" ofType:@"png"];
    img = [[UIImage alloc] initWithContentsOfFile:imagePath];
    if(_searchResult != nil){
        if([_searchResult isKindOfClass:[NSString class]]){
            //中文
            if(mapDispalyType == ChinaMap){
                //先遍历省，没有在遍历市
                
            }else{
                
            }
        }else if([_searchResult isKindOfClass:[NSArray class]]){
            //纬度
            NSArray *temp = (NSArray *)_searchResult;
            double oneNumber = [(NSString *)[temp objectAtIndex:0] doubleValue];
            //经度
            double twoNumber = [(NSString *)[temp objectAtIndex:1] doubleValue];
            //将纬度和经度转换为投影平面坐标
            if(![self convertlat:oneNumber andLon:twoNumber toX:&xTemp toY:&yTemp andType:LocImageType] ){
                return NO;
            }
            cgImage= [img CGImage];
            CGPoint p =  CGPointMake(xTemp-[img size].width/2, yTemp);
            
            CGContextDrawImage(context, CGRectMake(p.x, p.y, 40, 40), cgImage);
        
            
            if(![self convertlat:oneNumber andLon:twoNumber toX:&xTemp toY:&yTemp andType:LocCharacterType]){
                return NO;
            }
            //写上搜索信息
            NSString *info = [NSString stringWithFormat:@"[经纬度:%.2f,%.2f]",oneNumber,twoNumber];
            //paste
            {
                    //创建AttributeString
                    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]
                                                         initWithString:info];
                    //创建字体以及字体大小
                    //CTFontRef helvetica = CTFontCreateWithName(CFSTR("Georgia"),20, NULL);
                    CTFontRef font = CTFontCreateWithName((CFStringRef)[UIFont boldSystemFontOfSize:15].fontName, 20, NULL);
                
                    [string addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor blueColor].CGColor range:NSMakeRange(0, [string length])];
                    //添加字体 目标字符串从下标0开始到字符串结尾
                    [string addAttribute:(id)kCTFontAttributeName
                                   value:(__bridge id)font
                                   range:NSMakeRange(0, [string length])];
                
                
                
                    //创建文本对齐方式
                    CTTextAlignment alignment = kCTLeftTextAlignment;//左对齐kCTRightTextAlignment为右对齐
                    CTParagraphStyleSetting alignmentStyle;
                    alignmentStyle.spec=kCTParagraphStyleSpecifierAlignment;//指定为对齐属性
                    alignmentStyle.valueSize=sizeof(alignment);
                    alignmentStyle.value=&alignment;
                    // layout master
                    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
                    
                    CGMutablePathRef leftColumnPath = CGPathCreateMutable();
                    
                    CGPathAddRect(leftColumnPath, NULL,
                                      CGRectMake(xTemp-20 , -(yTemp-55),self.bounds.size.width,self.bounds.size.height));
                    CTFrameRef leftFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0, 0),leftColumnPath,NULL);
                    // draw
                    CTFrameDraw(leftFrame, context);
                    // cleanup
                    CGPathRelease(leftColumnPath);
                    CFRelease(framesetter);
                    CFRelease(font);
            }
        }
    }
    return YES;
}

#pragma mark-纬度 经度转换为投影平面XY
-(BOOL)convertlat:(double)lat andLon:(double)lon toX:(double *)x toY:(double *)y andType:(int)type{
    BOOL done;
    if (mapDispalyType == ChinaMap) {
        //ChinaMap
        if(projectionPattern == TwoDimentionsProjectionPattern){
            *x = (lon - (extendLeft+extendRight)/2) * (pScale );
            *y = (lat - (extendBottom+extendTop)/2) * (pScale );
        }else if(projectionPattern == OrthographicProjectionPattern){
            done = [orthographic_projection transit_to_xy:x andY:y andLat:j2h(lat) andLon:j2h(lon)];
            if(!done){
                return NO;
            }
            *x /= pScale;
            *y /= pScale;
        }else{
            done = [mercator_projection toProj:j2h(lat) andL:j2h(lon) andX:y andY:x];
            if(done == 1){
                return NO;
            }
            double tempx;
            double tempy;
            *x /= pScale;
            *y /= pScale;
            done = [mercator_projection toProj:j2h((extendBottom+extendTop)/2) andL:j2h((extendLeft+extendRight)/2) andX:&tempy andY:&tempx];
            if(!done){
                *x -= tempx/pScale;
                *y -= tempy/pScale;
            }
        }
    }else{
        //WorldMap
        if(projectionPattern == OrthographicProjectionPattern){
            done = [orthographic_projection transit_to_xy:x andY:y andLat:j2h(lat) andLon:j2h(lon)];
            if(!done){
                return NO;
            }
            *x /= pScale;
            *y /= pScale;
        }else{
            done = [mercator_projection toProj:j2h(lat) andL:j2h(lon) andX:y andY:x];
            if(done == 1){
                return NO;
            }
            *x /= pScale;
            *y /= pScale;
        }
    }
    if(type == LocCharacterType){
        *y = (*y)*(-1)+self.bounds.size.height;
    }
    return YES;
}



#pragma mark-
- (BOOL) updateViewSize:(double)x andHeight:(double)y {
    if(fabs(x) > self.bounds.size.width/2 || fabs(y) > self.bounds.size.height/2){
        //修改大小
        CGRect origionRect = self.frame;
        CGRect newRect = CGRectMake(origionRect.origin.x, origionRect.origin.y, origionRect.size.width*1.5, origionRect.size.height*1.5);
        self.frame = newRect;
        //[self updateViewSize:x andHeight:y];
    }
    return YES;
}

-(void)dealloc{
    if (cgImage != nil) {
        CGImageRelease(cgImage);
    }
}



@end
