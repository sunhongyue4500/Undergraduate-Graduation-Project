#include <cmath>
#include "orthographic_projection.h"

const double Orthographic_projection::pi = 3.1415926535897932384626433832795;

//构造
Orthographic_projection::Orthographic_projection(void):
	m_no_mask(false),
	m_earth_radius(6371288.0 / 2.0)
{
	//设置默认的投影中心点
	set_center(0.69944069773672757795216907547181, 2.0348793749001888537353310669809);
}

//析构
Orthographic_projection::~Orthographic_projection(void)
{
}

//设置投影中心点
void Orthographic_projection::set_center(const double latitude, const double longitude)
{
	//记录中心点
	m_center_latitude = latitude;
	m_center_longitude = longitude;

	//计算中心点纬度正余弦
	m_sin_center_latitude = sin(m_center_latitude);
	m_cos_center_latitude = cos(m_center_latitude);
}

bool Orthographic_projection::transit_to_xy(double& x, double& y, const double latitude, const double longitude)
{
	bool done = true;
	bool visible = true;
	double radius = m_earth_radius;

	if(radius <= 0.0 ) 
		done = false;

	if( (fabs(latitude) > pi/2) || (fabs(longitude) > pi) )
	{
		done = false;
		visible = false;
	}

	if(done || m_no_mask)
	{
		double lambda = get_lambda(m_center_longitude, longitude);

		double sin_latitude = sin(latitude);
		double cos_latitude = cos(latitude);
		double sin_lambda = sin(lambda);
		double cos_lambda = cos(lambda);

		if((m_sin_center_latitude * sin_latitude + m_cos_center_latitude * cos_latitude * cos_lambda) <= 0.0)
			visible = false;

		if (visible || m_no_mask)
		{
			x = radius * cos_latitude * sin_lambda;
			y = radius * (m_cos_center_latitude * sin_latitude - m_sin_center_latitude * cos_latitude * cos_lambda);
		}

		done = visible;
	}

	return done;
}

double Orthographic_projection::get_lambda (double central_meridian, double longitude)
{
	double lambda ;
	lambda = longitude - central_meridian;
	if( (longitude < 0.0) && (central_meridian > 0.0) )
	{
		if( lambda < -pi )
			lambda = 2.0 * pi + lambda;
	}
	if( (longitude > 0.0) && (central_meridian < 0.0))
	{
		if( lambda > pi)
			lambda -= 2.0 * pi;
	}
	return  lambda;
}

bool Orthographic_projection::xy_to_transit(double& latitude, double& longitude, const double x, const double y)
{
	bool visible = false;
	double radius = m_earth_radius;

	if(radius > 0.0)
	{
		visible = true;
		
		double distance_to_center = sqrt(x * x + y * y);
		double sin_c = distance_to_center / radius;
		double cos_c = sqrt(radius * radius - x * x - y * y) / radius;
		double lambda;
        
		if(fabs(sin_c) <= 1.0 )
		{
			if(distance_to_center > 0.0)
			{
				//º∆À„Œ≥∂»
				if(fabs(m_center_latitude - (pi / 2.0)) < 0.00001)
				{
					latitude = asin(cos_c);
					lambda = atan2(x * sin_c, -y * sin_c);
				}
				else if(fabs(m_center_latitude - (-pi / 2.0)) < 0.00001)
				{
					latitude = asin(cos_c);
					lambda = atan2(x * sin_c, y * sin_c);
				}
				else if(fabs(m_center_latitude - 0.0) < 0.00001)     //if  Equator
				{
					latitude = asin(y * sin_c / distance_to_center);
					lambda = atan2(x * sin_c, distance_to_center * cos_c);
				}
				else
				{
					latitude = asin(cos_c * m_sin_center_latitude + y * sin_c * m_cos_center_latitude / distance_to_center);
					lambda = atan2(x * sin_c, (distance_to_center * m_cos_center_latitude * cos_c - y * m_sin_center_latitude * sin_c));
				}

                //计算精度
				longitude = m_center_longitude + lambda;
				if(fabs(longitude) > pi)
				{
					if( longitude > pi )
						longitude -=  2.0 * pi;
					else
						longitude += 2.0 * pi ;
				}
			}
			else
			{
				latitude = m_center_latitude;
				longitude = m_center_longitude;
			}
		}
		else
			visible = false;

		return(visible);
	}
	else
	{
		return false;
	}
}

