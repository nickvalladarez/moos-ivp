// Example: BHV_PatrolFormation - UUVs patrol in formation
// Based on MOOS-IvP behavior architecture

#include "BHV_PatrolFormation.h"
#include "MBUtils.h"
#include "AngleUtils.h"
#include "GeomUtils.h"
#include "ZAIC_PEAK.h"
#include "OF_Coupler.h"

BHV_PatrolFormation::BHV_PatrolFormation(IvPDomain domain) : 
  IvPContactBehavior(domain)
{
  this->setParam("descriptor", "patrol_formation");
  
  // Default formation parameters
  m_formation_type = "line";      // line, diamond, circle
  m_formation_spacing = 30;       // meters between vehicles
  m_formation_heading = 0;        // formation orientation
  m_my_position_in_formation = 0; // 0=leader, 1=right wing, etc.
  m_max_formation_range = 200;    // max distance to maintain formation
  
  // Speed coordination
  m_formation_speed = 3.0;
  m_speed_tolerance = 0.5;
  
  // Formation keeping parameters
  m_position_tolerance = 10;      // acceptable position error
  m_heading_tolerance = 15;       // acceptable heading error
}

IvPFunction* BHV_PatrolFormation::onRunState() 
{
  if(!updatePlatformInfo())
    return(0);
    
  // Calculate my assigned position in formation
  XYPoint formation_position = calculateFormationPosition();
  
  // Calculate desired heading and speed
  double desired_heading = calculateFormationHeading();
  double desired_speed = calculateFormationSpeed();
  
  // Create heading objective function
  ZAIC_PEAK hdg_zaic(m_domain, "course");
  hdg_zaic.setSummit(desired_heading);
  hdg_zaic.setPeakWidth(m_heading_tolerance);
  hdg_zaic.setBaseWidth(m_heading_tolerance * 2);
  hdg_zaic.setValueWrap(true);
  
  IvPFunction *hdg_ipf = hdg_zaic.extractIvPFunction();
  if(!hdg_ipf)
    return(0);
    
  // Create speed objective function
  ZAIC_PEAK spd_zaic(m_domain, "speed");
  spd_zaic.setSummit(desired_speed);
  spd_zaic.setPeakWidth(m_speed_tolerance);
  spd_zaic.setBaseWidth(m_speed_tolerance * 2);
  
  IvPFunction *spd_ipf = spd_zaic.extractIvPFunction();
  if(!spd_ipf) {
    delete hdg_ipf;
    return(0);
  }
  
  // Couple the objectives
  OF_Coupler coupler;
  IvPFunction *ipf = coupler.couple(hdg_ipf, spd_ipf, 0.6, 0.4);
  
  return(ipf);
}

XYPoint BHV_PatrolFormation::calculateFormationPosition() 
{
  // Get leader position (contact position)
  double leader_x = m_cnx;
  double leader_y = m_cny;
  double leader_hdg = m_cnh;
  
  XYPoint my_position;
  
  if(m_formation_type == "line") {
    // Line formation: vehicles in a line behind leader
    double offset_distance = m_formation_spacing * m_my_position_in_formation;
    double offset_angle = leader_hdg + 180; // behind leader
    
    my_position.set_x(leader_x + offset_distance * cos(offset_angle * M_PI/180));
    my_position.set_y(leader_y + offset_distance * sin(offset_angle * M_PI/180));
  }
  else if(m_formation_type == "diamond") {
    // Diamond formation: leader at front, others at sides/rear
    double angle_offset = 0;
    switch(m_my_position_in_formation) {
      case 1: angle_offset = 45;  break;  // right front
      case 2: angle_offset = -45; break;  // left front  
      case 3: angle_offset = 135; break;  // right rear
      case 4: angle_offset = -135; break; // left rear
    }
    
    double formation_angle = leader_hdg + angle_offset;
    my_position.set_x(leader_x + m_formation_spacing * cos(formation_angle * M_PI/180));
    my_position.set_y(leader_y + m_formation_spacing * sin(formation_angle * M_PI/180));
  }
  
  return my_position;
}

double BHV_PatrolFormation::calculateFormationHeading() 
{
  // Generally follow leader's heading with small adjustments
  double base_heading = m_cnh;
  
  // Calculate position error
  XYPoint target_position = calculateFormationPosition();
  double position_error_x = target_position.x() - m_osx;
  double position_error_y = target_position.y() - m_osy;
  double distance_error = sqrt(position_error_x*position_error_x + 
                              position_error_y*position_error_y);
  
  // If far from formation position, head toward it
  if(distance_error > m_position_tolerance) {
    double angle_to_position = atan2(position_error_y, position_error_x) * 180/M_PI;
    
    // Blend formation heading with correction heading
    double correction_weight = std::min(distance_error / m_formation_spacing, 1.0);
    return base_heading * (1 - correction_weight) + angle_to_position * correction_weight;
  }
  
  return base_heading;
}

double BHV_PatrolFormation::calculateFormationSpeed() 
{
  // Base speed from formation parameters
  double base_speed = m_formation_speed;
  
  // Adjust speed based on position in formation
  XYPoint target_position = calculateFormationPosition();
  double distance_to_target = distPointToPoint(m_osx, m_osy, 
                                              target_position.x(), target_position.y());
  
  // Speed up if falling behind, slow down if getting ahead
  if(distance_to_target > m_position_tolerance) {
    base_speed *= 1.2; // speed up to catch formation
  } else if(distance_to_target < m_position_tolerance * 0.5) {
    base_speed *= 0.8; // slow down to maintain spacing
  }
  
  return base_speed;
}

double BHV_PatrolFormation::getRelevance() 
{
  // High relevance when in formation mode and contact is available
  if(m_contact_range > m_max_formation_range)
    return 0; // too far from formation
    
  return 1.0; // full relevance when in range
}
