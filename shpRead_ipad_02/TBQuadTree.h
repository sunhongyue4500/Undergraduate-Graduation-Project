//
//  TBQuadTree.h
//  TBQuadTree
//
//  Created by Theodore Calmes on 9/19/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct TBQuadTreeNodeData {
    //经纬度
    double x;
    double y;
    //保存的数据
    void* data;
} TBQuadTreeNodeData;

//构建节点
TBQuadTreeNodeData TBQuadTreeNodeDataMake(double x, double y, void* data);
TBQuadTreeNodeData TBQuadTreeNodeDataMakeFP(double x, double y);


typedef struct TBBoundingBox {
    double x0; double y0;
    double xf; double yf;
} TBBoundingBox;

//构建边界
TBBoundingBox TBBoundingBoxMake(double x0, double y0, double xf, double yf);

//节点
typedef struct quadTreeNode {
    struct quadTreeNode* northWest;    //第一象限
    struct quadTreeNode* northEast;
    struct quadTreeNode* southWest;
    struct quadTreeNode* southEast;    //第四象限
    TBBoundingBox boundingBox;         //该节点所表示的区域的边界
    int bucketCapacity;                //该节点的容量
    TBQuadTreeNodeData *points;        //保存该区域的节点
    int count;                         //节点的数量
} TBQuadTreeNode;

//构建节点
TBQuadTreeNode* TBQuadTreeNodeMake(TBBoundingBox boundary, int bucketCapacity);


//释放节点
void TBFreeQuadTreeNode(TBQuadTreeNode* node);

//判断box是否包含data
bool TBBoundingBoxContainsData(TBBoundingBox box, TBQuadTreeNodeData data);
//判断两个box的是否交集
bool TBBoundingBoxIntersectsBoundingBox(TBBoundingBox b1, TBBoundingBox b2);

//
typedef void(^TBQuadTreeTraverseBlock)(TBQuadTreeNode* currentNode);
void TBQuadTreeTraverse(TBQuadTreeNode* node, TBQuadTreeTraverseBlock block);

typedef void(^TBDataReturnBlock)(TBQuadTreeNodeData data);
void TBQuadTreeGatherDataInRange(TBQuadTreeNode* node, TBBoundingBox range, TBDataReturnBlock block);

//插入数据
bool TBQuadTreeNodeInsertData(TBQuadTreeNode* node, TBQuadTreeNodeData data);
TBQuadTreeNode* TBQuadTreeBuildWithData(TBQuadTreeNodeData *data, int count, TBBoundingBox boundingBox, int capacity);
