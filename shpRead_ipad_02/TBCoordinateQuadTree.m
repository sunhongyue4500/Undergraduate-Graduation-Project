//
//  TBCoordinateQuadTree.m
//  TBAnnotationClustering
//
//  Created by Theodore Calmes on 9/27/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import "TBCoordinateQuadTree.h"
#import "TBClusterAnnotation.h"
#import "Shapefile.h"
#import "ShapePolyline.h"
#import "ShapePoint.h"
#import "orthographic_projection_oc.h"

typedef struct TBHotelInfo {
    char* hotelName;
    char* hotelPhoneNumber;
} TBHotelInfo;

TBQuadTreeNodeData TBDataFromLine(NSString *line)
{
    NSArray *components = [line componentsSeparatedByString:@","];
    double latitude = [components[1] doubleValue];
    double longitude = [components[0] doubleValue];

    TBHotelInfo* hotelInfo = malloc(sizeof(TBHotelInfo));

    NSString *hotelName = [components[2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    hotelInfo->hotelName = malloc(sizeof(char) * hotelName.length + 1);
    strncpy(hotelInfo->hotelName, [hotelName UTF8String], hotelName.length + 1);

    NSString *hotelPhoneNumber = [[components lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    hotelInfo->hotelPhoneNumber = malloc(sizeof(char) * hotelPhoneNumber.length + 1);
    strncpy(hotelInfo->hotelPhoneNumber, [hotelPhoneNumber UTF8String], hotelPhoneNumber.length + 1);

    return TBQuadTreeNodeDataMake(latitude, longitude, hotelInfo);
}

TBQuadTreeNodeData TBDataFromPoint(double x,double y)
{
    return TBQuadTreeNodeDataMakeFP(x, y);
}

//TBBoundingBox TBBoundingBoxForMapRect(MKMapRect mapRect)
//{
//    CLLocationCoordinate2D topLeft = MKCoordinateForMapPoint(mapRect.origin);
//    CLLocationCoordinate2D botRight = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)));
//
//    CLLocationDegrees minLat = botRight.latitude;
//    CLLocationDegrees maxLat = topLeft.latitude;
//
//    CLLocationDegrees minLon = topLeft.longitude;
//    CLLocationDegrees maxLon = botRight.longitude;
//
//    return TBBoundingBoxMake(minLat, minLon, maxLat, maxLon);
//}

//MKMapRect TBMapRectForBoundingBox(TBBoundingBox boundingBox)
//{
//    MKMapPoint topLeft = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.x0, boundingBox.y0));
//    MKMapPoint botRight = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.xf, boundingBox.yf));
//
//    return MKMapRectMake(topLeft.x, botRight.y, fabs(botRight.x - topLeft.x), fabs(botRight.y - topLeft.y));
//}
//
//NSInteger TBZoomScaleToZoomLevel(MKZoomScale scale)
//{
//    double totalTilesAtMaxZoom = MKMapSizeWorld.width / 256.0;
//    NSInteger zoomLevelAtMaxZoom = log2(totalTilesAtMaxZoom);
//    NSInteger zoomLevel = MAX(0, zoomLevelAtMaxZoom + floor(log2f(scale) + 0.5));
//
//    return zoomLevel;
//}
//
//float TBCellSizeForZoomScale(MKZoomScale zoomScale)
//{
//    NSInteger zoomLevel = TBZoomScaleToZoomLevel(zoomScale);
//
//    switch (zoomLevel) {
//        case 13:
//        case 14:
//        case 15:
//            return 64;
//        case 16:
//        case 17:
//        case 18:
//            return 32;
//        case 19:
//            return 16;
//
//        default:
//            return 88;
//    }
//}

@implementation TBCoordinateQuadTree

- (void)buildTree:(Shapefile *)shp withOrProjection:(orthographic_projection_oc *)proj
{
    @autoreleasepool {
//        NSString *data = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"USA-HotelMotel" ofType:@"csv"] encoding:NSASCIIStringEncoding error:nil];
//        NSArray *lines = [data componentsSeparatedByString:@"\n"];
//
//        NSInteger count = lines.count - 1;
        //从文件读取出数据，有多少个Hotel就有多少节点，分配节点

//        for (NSInteger i = 0; i < count; i++) {
//            dataArray[i] = TBDataFromLine(lines[i]);
//        }

        
    
        
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
        
        BOOL hasStartPointFlag = NO;
        //double nZoom = scale;
        nShapeCount = [shp->m_objList count];
        //创建节点
        TBQuadTreeNodeData *dataArray = malloc(sizeof(TBQuadTreeNodeData) * nShapeCount);
        {
            for(i = 0; i < nShapeCount; i++)
            {
                ShapePolyline* shapePolyline;
                shapePolyline = [[ShapePolyline alloc] init];
                
                shapePolyline = [shp->m_objList objectAtIndex:i];
                nPartsCount = [shapePolyline->m_Parts count];
                
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
                    
                        
                        done = [proj transit_to_xy:&x andY:&y andLat:j2h(nNorth) andLon:j2h(nEast)];
                        if(!done){
                            continue;
                        }
                        x /= 10000;
                        y /= 10000;
                        dataArray[i] = TBDataFromPoint(x, y);
                    }
                }
            }
        }

        
        
        
        TBBoundingBox world = TBBoundingBoxMake(19, -166, 72, -53);
        _root = TBQuadTreeBuildWithData(dataArray, nShapeCount, world, 4);
    }
}

 
//- (NSArray *)clusteredAnnotationsWithinMapRect:(MKMapRect)rect withZoomScale:(double)zoomScale
//{
//    double TBCellSize = TBCellSizeForZoomScale(zoomScale);
//    double scaleFactor = zoomScale / TBCellSize;
//
//    NSInteger minX = floor(MKMapRectGetMinX(rect) * scaleFactor);
//    NSInteger maxX = floor(MKMapRectGetMaxX(rect) * scaleFactor);
//    NSInteger minY = floor(MKMapRectGetMinY(rect) * scaleFactor);
//    NSInteger maxY = floor(MKMapRectGetMaxY(rect) * scaleFactor);
//
//    NSMutableArray *clusteredAnnotations = [[NSMutableArray alloc] init];
//    for (NSInteger x = minX; x <= maxX; x++) {
//        for (NSInteger y = minY; y <= maxY; y++) {
//            MKMapRect mapRect = MKMapRectMake(x / scaleFactor, y / scaleFactor, 1.0 / scaleFactor, 1.0 / scaleFactor);
//            
//            __block double totalX = 0;
//            __block double totalY = 0;
//            __block int count = 0;
//
//            NSMutableArray *names = [[NSMutableArray alloc] init];
//            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
//
//            TBQuadTreeGatherDataInRange(self.root, TBBoundingBoxForMapRect(mapRect), ^(TBQuadTreeNodeData data) {
//                totalX += data.x;
//                totalY += data.y;
//                count++;
//
//                TBHotelInfo hotelInfo = *(TBHotelInfo *)data.data;
//                [names addObject:[NSString stringWithFormat:@"%s", hotelInfo.hotelName]];
//                [phoneNumbers addObject:[NSString stringWithFormat:@"%s", hotelInfo.hotelPhoneNumber]];
//            });
//
//            if (count == 1) {
//                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX, totalY);
//                TBClusterAnnotation *annotation = [[TBClusterAnnotation alloc] initWithCoordinate:coordinate count:count];
//                annotation.title = [names lastObject];
//                annotation.subtitle = [phoneNumbers lastObject];
//                [clusteredAnnotations addObject:annotation];
//            }
//
//            if (count > 1) {
//                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX / count, totalY / count);
//                TBClusterAnnotation *annotation = [[TBClusterAnnotation alloc] initWithCoordinate:coordinate count:count];
//                [clusteredAnnotations addObject:annotation];
//            }
//        }
//    }
//
//    return [NSArray arrayWithArray:clusteredAnnotations];
//}

@end
