//
//  TBCoordinateQuadTree.h
//  TBAnnotationClustering
//
//  Created by Theodore Calmes on 9/27/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TBQuadTree.h"
#import "Shapefile.h"
@class orthographic_projection_oc;

@interface TBCoordinateQuadTree : NSObject


@property (assign, nonatomic) TBQuadTreeNode* root;
@property (strong, nonatomic) UIView *mapView;

- (void)buildTree:(Shapefile *)shp withOrProjection:(orthographic_projection_oc *)proj;
//- (NSArray *)clusteredAnnotationsWithinMapRect:(MKMapRect)rect withZoomScale:(double)zoomScale;

@end
