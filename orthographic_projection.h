#ifndef _ORTHOGRAPHIC_PROJECTION_H
#define _ORTHOGRAPHIC_PROJECTION_H

/*
 *	正射投影
 */
class Orthographic_projection{
    
public:
	Orthographic_projection(void);
	virtual ~Orthographic_projection(void);

	//设置投影中心点
	void set_center(const double latitude, const double longitude);

	//经纬度转换为平面坐标
	bool transit_to_xy(double& x, double& y, const double latitude, const double longitude);

	//平面坐标转为经纬度
	bool xy_to_transit(double& latitude, double& longitude, const double x, const double y);

private:
	//不进行遮挡变换
	bool m_no_mask;

	//中心点
	double m_center_latitude;
	double m_center_longitude;
	double m_sin_center_latitude;
	double m_cos_center_latitude;

	//地球参数
	double m_earth_radius;

	//圆周率
	static const double pi;

	//计算Lambda参数
	inline double get_lambda (double central_meridian, double longitude);
};


#endif

