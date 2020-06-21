# importing packages
import numpy as np
from scipy.spatial import ConvexHull
import xmltodict
import time
import json
import collections
import math
import requests
from shapely.geometry import Point, Polygon
from scipy.ndimage.interpolation import rotate
from flask import Flask,jsonify, request


app = Flask(__name__)



@app.route('/getRoute', methods=['GET'])
def zone_data():
    start_lat = float(request.args.get('st_lat'))
    start_lng = float(request.args.get('st_lng'))
    end_lat = float(request.args.get('e_lat'))
    end_lng = float(request.args.get('e_lng'))
    lang = str(request.args.get('lang'))
    print("STARTING LAT",start_lat)
    print("STARTING LONG",start_lng)
    print("ENDING LAT",end_lat)
    print("ENDING LONG",end_lng)
    print("LANGUAGE",lang)
    accesskey = '1m-furr_5hkuA_PIN4j3yvZ8mqIfoRpLuVXDvKAI_r4'
    warning = 0
    dangerpoints = []
    touch_poly = []
    count = 1
       # function to find minimum_bounding_rectangle
    def minimum_bounding_rectangle(points):
        pi2 = np.pi / 2.
        hull_points = points[ConvexHull(points).vertices]
        edges = np.zeros((len(hull_points) - 1, 2))
        edges = hull_points[1:] - hull_points[:-1]
        angles = np.zeros((len(edges)))
        angles = np.arctan2(edges[:, 1], edges[:, 0])
        angles = np.abs(np.mod(angles, pi2))
        angles = np.unique(angles)
        rotations = np.vstack([
            np.cos(angles),
            np.cos(angles - pi2),
            np.cos(angles + pi2),
            np.cos(angles)]).T
        rotations = rotations.reshape((-1, 2, 2))
        rot_points = np.dot(rotations, hull_points.T)
        min_x = np.nanmin(rot_points[:, 0], axis=1)
        max_x = np.nanmax(rot_points[:, 0], axis=1)
        min_y = np.nanmin(rot_points[:, 1], axis=1)
        max_y = np.nanmax(rot_points[:, 1], axis=1)
        areas = (max_x - min_x) * (max_y - min_y)
        best_idx = np.argmin(areas)
        x1 = max_x[best_idx]
        x2 = min_x[best_idx]
        y1 = max_y[best_idx]
        y2 = min_y[best_idx]
        r = rotations[best_idx]
        rval = np.zeros((4, 2))
        rval[0] = np.dot([x1, y2], r)
        rval[1] = np.dot([x2, y2], r)
        rval[2] = np.dot([x2, y1], r)
        rval[3] = np.dot([x1, y1], r)
        return rval
   
    # declaring lists
    coords = []
    gcoords = []
    mbrct = []  
    timestamp = int(time.time())
    # getting the quarantined zones and parsing xml files and converting them into ordered.dictionaries
    response = requests.get("https://covid.gccservice.in/api/csr/""hotspots?dummy={tp}".format(tp = timestamp))
    dict_data = xmltodict.parse(response.text)

    

    def radians(degrees):
        return degrees * math.pi / 180.0

    def degrees(radians):
        return radians * 180.0 / math.pi

    def LatLonDestPoint(origin, bearing, distance):
        brng = radians(bearing)
        lat1 = radians(origin[0])
        lon1 = radians(origin[1])

        lat2 = math.asin(math.sin(lat1) * math.cos(distance / 6371.0) + math.cos(lat1) * math.sin(distance / 6371.0) * math.cos(brng))
        lon2 = lon1 + math.atan2(math.sin(brng) * math.sin(distance / 6371.0) * math.cos(lat1),math.cos(distance / 6371.0) - math.sin(lat1) * math.sin(lat2))
        lon2 = math.fmod(lon2 + math.pi, 2.0 * math.pi) - math.pi

        coordinate = [0,0]
        if (np.isnan(lat2) == False) or (np.isnan(lon2) == False):
            coordinate[0] = degrees(lat2)
            coordinate[1] = degrees(lon2)

        return coordinate

    
    gcoords = [[13.0109, 80.2354]]

    for i in dict_data['kml']['Document']['Placemark']:
        coords.append( [ float(i['Point']['coordinates'].split(',')[1]) , float(i['Point']['coordinates'].split(',')[0]) ])
    
    #new change
    for _gcoord in coords:
        mbrct.append([LatLonDestPoint(_gcoord, 0.0,0.096),LatLonDestPoint(_gcoord, 90.0,0.096),LatLonDestPoint(_gcoord, 180.0,0.096),LatLonDestPoint(_gcoord, 270.0,0.096)])
        
    def checker(warning,dangerpoints,lang):
        start_point=Point(start_lat,start_lng)
        end_point=Point(end_lat,end_lng)
        for br in mbrct:
            if (start_point.within(Polygon(br))):
                warning = 1
            if (end_point.within(Polygon(br))):
                warning = 2
        return getsafestroute(start_lat,start_lng,end_lat,end_lng,touch_poly,warning,dangerpoints,lang)
   
    #getting routes using this funct
    #getting routes using this funct
    def getsafestroute(start_lat,start_lng,end_lat,end_lng,touch_poly,warning,dangerpoints,lang):
            inter = 1
            dangerpoints=[]
            if len(touch_poly)==0:
                get_string = string
            else:
                get_string = string + "&avoidareas="
                for i in touch_poly:
                    get_string+=str(i[0][0])
                    get_string+=","
                    get_string+=str(i[0][1])
                    get_string+=";"
                    get_string+=str(i[2][0])
                    get_string+=","
                    get_string+=str(i[2][1])
                    get_string+="!"
                    get_string = get_string[0:len(get_string)-1]
        #print(get_string.format(key = accesskey, start_lat = start_lat , start_lng = start_lng , end_lat =  end_lat, end_lng= end_lng,lang=lang))
            routeresponse = requests.get(get_string.format(key = accesskey, start_lat = start_lat , start_lng = start_lng , end_lat =  end_lat, end_lng= end_lng,lang=lang))
            routeresponse = json.loads(routeresponse.text)
            coordinates_of_route = routeresponse['response']['route'][0]['shape']
            length = routeresponse['response']['route'][0]['summary']['distance']
            time = routeresponse['response']['route'][0]['summary']['travelTime']
            maneuver = routeresponse['response']['route'][0]['leg'][0]['maneuver']
            linkroads = routeresponse['response']['route'][0]['leg'][0]['link']
    #print(coordinates_of_route)
            for pt in coordinates_of_route:
                        point = Point(float(pt.split(',')[0]),float(pt.split(',')[1]))
                        for bd in mbrct:
                            if (point.within(Polygon(bd))):
                                dangerpoints.append(pt)
                                if bd not in touch_poly:
                                    touch_poly.append(bd)
                                    inter = 0
            if len(touch_poly) == 0:
                        print('possible da machi')
                        return coordinates_of_route,warning,dangerpoints,length,time,maneuver,get_string.format(key = accesskey, start_lat = start_lat , start_lng = start_lng , end_lat =  end_lat, end_lng= end_lng,lang=lang),linkroads
            elif len(routeresponse['response']['route'][0]['note']) == 0 and inter == 1:
                        print('second time la possible')
                        return coordinates_of_route,warning,dangerpoints,length,time,maneuver,get_string.format(key = accesskey, start_lat = start_lat , start_lng = start_lng , end_lat =  end_lat, end_lng= end_lng,lang=lang),linkroads
            elif len(routeresponse['response']['route'][0]['note']) == 1 or len(touch_poly) > 20:
                        print('not possible')
                        if warning == 0:
                            warning = 3
                        return coordinates_of_route,warning,dangerpoints,length,time,maneuver,get_string.format(key = accesskey, start_lat = start_lat , start_lng = start_lng , end_lat =  end_lat, end_lng= end_lng,lang=lang),linkroads
            else:
                        return getsafestroute(start_lat,start_lng,end_lat,end_lng,touch_poly,warning,dangerpoints,lang)
        
       
       
    string = "https://route.ls.hereapi.com/routing/7.2/calculateroute.json?apiKey={key}&waypoint0=geo!{start_lat},{start_lng}&waypoint1=geo!{end_lat},{end_lng}&mode=fastest;car;traffic:disabled&instructionFormat=text&language={lang}&legattributes=li&linkattributes=rt,rd&maneuverattributes=ac&routeattributes=sh,no"
    route_coords = checker(warning,dangerpoints,lang)

    return jsonify({'route':route_coords[0],'warning':route_coords[1],'dangerpoints':route_coords[2],'distance':route_coords[3],'duration':route_coords[4],'maneuver':route_coords[5],'http':route_coords[6],'linkroads':route_coords[7]})

if __name__ == '__main__':
   app.run()








   
   
