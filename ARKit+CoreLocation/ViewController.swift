//
//  ViewController.swift
//  ARKit+CoreLocation
//
//  Created by Andrew Hart on 02/07/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
// 

import UIKit
import SceneKit
import MapKit
import ARKit
import CocoaLumberjack
// 高度
let Altitude: CLLocationDistance = 8

@available(iOS 11.0, *)
class ViewController: UIViewController,ARSCNViewDelegate{
    // 测试数据
    let l1 = CLLocationCoordinate2D(latitude: 31.910121, longitude: 118.892977);
    //let l2 = CLLocationCoordinate2D(latitude: 31.910321, longitude: 118.894429);
    let sc = CLLocationCoordinate2D(latitude: 31.909738, longitude: 118.892276);
    // 这个View是ARSCNView的子类
    let sceneLocationView = SceneLocationView()
    
    let mapView = MKMapView()
    var userAnnotation: MKPointAnnotation?
    var locationEstimateAnnotation: MKPointAnnotation?
    // 获取经纬度组
    var routeCoordinates = [CLLocationCoordinate2D]()
    
    
    let metersPerNode: CLLocationDistance = 5

    var adjustNorthByTappingSidesOfScreen = true
    // 显示经纬度按钮
    var AVC = AVCaptureViewController()
    var searchVC = SearchViewController()
    var shadowView1 = UIView()
    var searchBar = UISearchBar()
    //var searchBar: UISearchBar?
    
    let kScreenWitdh  = UIScreen.main.bounds.width
    let kScreenHeight = UIScreen.main.bounds.height
    
    let Y3 = UIScreen.main.bounds.height - 60
    let Y1 = 50
    let Y2 = UIScreen.main.bounds.height - 250
    var tableView = UITableView()
    var searchResultsWrapperView = UIView()
    /* 路线细节展示按钮 **/
    var routeDetailLabel = UILabel()
    // -------用于根据所提供的部分搜索字符串生成完成字符串列表
    fileprivate lazy var localSearchCompleter: MKLocalSearchCompleter = MKLocalSearchCompleter()
    // 创建导航管理
    fileprivate lazy var locationManager: CLLocationManager = CLLocationManager()
    // -------地图信息展示按钮
    let routeDetailWrapperView = UIView()
    // -------取消按钮
    let goButton = UIButton()
    // -------go按钮
    let cancelButton = UIButton()
    let text = UITextView()
    var i = 1
    // 添加触摸事件
    //var tapGR = UITapGestureRecognizer()
    
    // 雷达
    var radarView = RadarView()
    // 雷达点
    //var arcView = ArcView()
    
    //创建一个按钮
    var world = UIButton()
    
    // 创建一个label
    public var showLabel = UILabel()
    
    //MARK: ---------------------------软件信息的管理 ---------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        // 地图与搜索面板
        shadowView1.layer.shadowColor = UIColor.black.cgColor
        shadowView1.alpha = 0.8
        shadowView1.backgroundColor = UIColor.white
        shadowView1.layer.shadowRadius = 10
        shadowView1.layer.shadowOffset = CGSize.init(width: 5, height: 5)
        shadowView1.layer.shadowOpacity = 0.8
        shadowView1.layer.cornerRadius = 10
        shadowView1.frame = CGRect(
            x: 0,
            y: Y3,
            width: kScreenWitdh,
            height: kScreenHeight)
        
        // 地图展示面板
        routeDetailWrapperView.backgroundColor =  UIColor.clear
        routeDetailWrapperView.isHidden = true
        routeDetailWrapperView.frame = CGRect(
            x: 40,
            y: 667,
            width: 300,
            height: 150)
        
        // 地图细节展示按钮
        routeDetailLabel.backgroundColor = UIColor(displayP3Red: 231.0/225.0, green: 226.0/225.0, blue: 204.0/225.0, alpha: 1.0)
        routeDetailLabel.layer.cornerRadius = 15
        routeDetailLabel.text = "sousuo"
        routeDetailLabel.textColor = UIColor.black
        routeDetailLabel.textAlignment = NSTextAlignment.center
        routeDetailLabel.font = UIFont.systemFont(ofSize: 24)
        routeDetailLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: 300,
            height: 60)
        
        // 取消按钮
        cancelButton.backgroundColor = UIColor(displayP3Red: 255.0/225.0, green: 73.0/225.0, blue: 49.0/225.0, alpha: 0.8)
        cancelButton.layer.cornerRadius = 15
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for:UIControlEvents.touchDragInside)
        cancelButton.frame = CGRect(
            x: 0,
            y: 70,
            width: 150,
            height: 70)
        // go按钮
        goButton.backgroundColor = UIColor(displayP3Red: 60.0/225.0, green: 217.0/225.0, blue: 64.0/225.0, alpha: 0.8)
        goButton.layer.cornerRadius = 15
        goButton.setTitle("Go", for: UIControlState.normal)
        goButton.addTarget(self, action:#selector(goButtonTapped), for: UIControlEvents.touchDragInside)
        goButton.frame = CGRect(
            x: 160,
            y: 70,
            width: 140,
            height: 70)

        // 搜索框
        searchBar.frame = CGRect(x: 0, y: 0, width: 375, height: 56)
        searchBar.placeholder = "搜索"
        searchBar.searchBarStyle = UISearchBarStyle.minimal
        searchBar.barTintColor = UIColor.white
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.frame = CGRect(
            x: 0,
            y: 0,
            width: 375,
            height: 56)
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(handleTapFrom(sender:)))
                //tapGR  = self.tapGR
        sceneLocationView.addGestureRecognizer(tapGR)
        //sceneLocationView.backgroundColor = .clear
        sceneLocationView.isUserInteractionEnabled = true
        sceneLocationView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height)
        //搜索底面板
        searchResultsWrapperView.isHidden = true
        searchResultsWrapperView.backgroundColor = UIColor.white
        searchResultsWrapperView.frame = CGRect(
            x: 0,
            y: 56,
            width: kScreenWitdh,
            height: kScreenHeight - 56)
        
        // 地图
        mapView.delegate = self
        mapView.showsCompass = true  //显示指南针
        mapView.showsTraffic = true  // 显示交通
        mapView.showsBuildings = true // 显示建筑物
        mapView.showsScale = true   // 显示比例尺
        mapView.userTrackingMode = .follow //地图定位追踪
        mapView.showsUserLocation = true // 显示用户位置
        mapView.alpha = 0.8
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: Constant.ViewController.AnnotationViewIdentifier)
        mapView.frame = CGRect(
            x: 0,
            y: 56,
            width: kScreenWitdh,
            height: kScreenHeight - 56)
        //地址tableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewCellIdentifier")   //添加cell注册
        
        let swipe1 = UIPanGestureRecognizer(target: self, action:#selector(swipe(sender:)))
        shadowView1.addGestureRecognizer(swipe1)  //添加向上滑动手势

        
        tableView.frame = CGRect(
            x: 0,
            y: 0,
            width: kScreenWitdh,
            height: kScreenHeight - 56)
        
        //雷达
        radarView.frame = CGRect(x: 250, y: 20, width: 120, height: 120)
        //雷达点
        //arcView.frame = radarView.frame
        // 世界按钮
        world.frame = CGRect(x: 20, y: 30, width: 30, height: 30)
        world.setImage(UIImage(named: "世界"), for: UIControlState.normal)
        //调用
        //RRAVC.startMotion()
        //
        showLabel.frame = CGRect(x: 140, y: 160, width: 100, height: 30)
        showLabel.text = "请对准路牌"
        
        sceneLocationView.addSubview(shadowView1)
        shadowView1.addSubview(searchBar)
        shadowView1.addSubview(mapView)
        shadowView1.addSubview(searchResultsWrapperView)
        searchResultsWrapperView.addSubview(tableView)
        routeDetailWrapperView.addSubview(cancelButton)
        routeDetailWrapperView.addSubview(goButton)
        // -------路牌细节按钮
        routeDetailWrapperView.addSubview(routeDetailLabel)
        // -------地图信息展示面板
        shadowView1.addSubview(routeDetailWrapperView)
        view.addSubview(sceneLocationView)
        view.addSubview(self.radarView)
        //view.addSubview(self.arcView)
        view.addSubview(world)
        view.addSubview(showLabel)
        
        
        
       let scene = SCNScene()
       self.sceneLocationView.scene = scene
//        self.sceneLocationView.isPlaying = true
        //sceneLocationView.allowsCameraControl = true
        // 导航管理
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        // 监听面板
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    
        // 设置搜索栏的代理
        localSearchCompleter.delegate = self
        localSearchCompleter.region = mapView.region
        //添加数据
        routeCoordinates = [l1,sc];
    }
    
    // 当程序将要启动时
    override func viewWillAppear(_ animated: Bool) {
        sceneLocationView.run()
    }
    // 当程序将要关闭时
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 暂停视图的会话
        sceneLocationView.pause()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // 释放未使用的所有缓存数据，图像等.
    }
    // 移除监听
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    //MARK: ---------------------------对视图的子控价进行布局 ---------------------------
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    //MARK: ---------------------------功能方法的调用 ---------------------------
    /// 设置AR导航标的方法
    func plotARRoute() {
        // 首先删除先前绘制的所有AR节点
        sceneLocationView.resetLocationNodes()
        
        // 为坐标系中的每个坐标添加一个AR注释（大头针）
        for coordinate in routeCoordinates {
            // TODO: 改变高度，使其不硬编码
            let nodeLocation = CLLocation(coordinate: coordinate, altitude: Altitude)
            let locationAnnotation = LocationAnnotationNode(location: nodeLocation, image: UIImage(named: "pin")!)
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: locationAnnotation)
    
        }
        // 计算距离
        let distance = Turf.distance(along: routeCoordinates)
        
        // 走路线并添加一个小的AR节点和每个节点的映射视图注释 （每米添加一个AR节点）（从0开始迭代）
        for i in stride(from: 0, to: distance, by: metersPerNode) {
            // 每段返回一个地址信息
            if let nextCoordinate = Turf.coordinate(at: i, fromStartOf: routeCoordinates) {
                //创建一个坐标信息
                let interpolatedStepLocation = CLLocation(coordinate: nextCoordinate, altitude: Altitude)
                
                // Add an AR node添加AR节点返回一个location节点————————实现原理1.创建一个平面 2. 想平面上添加图片 3. 添加到节点上
                let locationAnnotation = LocationAnnotationNode(location: interpolatedStepLocation, image: UIImage(named: "箭头")!)
                // 添加到场景中——————实现原理1.判断有没有值，更新节点位置，把节点附到根节点上
                sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: locationAnnotation)
            }
        }
    }
    
    
    
    // 添加触摸检测事件
    @objc func handleTapFrom(sender:UITapGestureRecognizer){
        showLabel.isHidden = true
        let tapPoint =  sender.location(in: self.sceneLocationView)
        // hii方法通过触摸屏幕上2维的点去检测3维坐标中的物体，以数组的形式返回，hitTest: 传给2维点，types:检测物体的类型
        // ————————————优先对已存在的平面锚进行命中测试（如果有锚点在他们的范围）
        let hitTestOptions: [SCNHitTestOption: Any] = [.boundingBoxOnly:true]
        let PlanHitTestResults = self.sceneLocationView.hitTest(tapPoint, options: hitTestOptions)
        // 收起键盘
        //searchBar.resignFir stResponder()
        // 当检测多个物体时，返回第一个
        //let hit = PlanHitTestResults.first
        if(PlanHitTestResults.count == 0){
            return
        }
        self.plotARRoute()
        
    }
    
    // 添加滑动触摸检测事件
    @objc func swipe(sender:UIPanGestureRecognizer){
        
        searchBar.resignFirstResponder()
        let recognizer = sender
        // 最后手指的结束点
        let point = recognizer.location(in: view)
        // 如果手势结束时的位置大于界面的一半，将会自动到达顶端否则恢复到原点
        if recognizer.state == .ended {
            let top = point.y > UIScreen.main.bounds.height/2 ?  searchWrapperViewDefaultTopConstant : Constant.ViewController.TopPadding
            //let top = point.y > kScreenHeight/2 ? Y3 : Y1
            //添加动画
            UIView.animate(withDuration: 0.25) {
                self.shadowView1.frame.origin.y = top
            }
        }else{
            shadowView1.frame.origin.y = point.y
        }
    }
    //  点击地图按钮之后要调用的
    @objc func directionButtonTapped(_ button: UIButton) {
        searchBar.resignFirstResponder()
        let annotation = button.layer.value(forKey: Constant.ViewController.AnnotationKeyPath) as! MKAnnotation
        // 提供行程的时间和距离
        let request = MKDirectionsRequest()
        request.source = mapView.userLocation.mapItem
        request.destination = annotation.mapItem
        request.transportType = .any
        request.requestsAlternateRoutes = true
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if let response = response,
                let route = response.routes.first {
                strongSelf.mapView.add(route.polyline, level: .aboveRoads)
                // 给细节按钮赋
                strongSelf.routeDetailLabel.text = "\(route.distance.distanceString)・\(route.expectedTravelTime.timeString)"
                // 显示面板
                strongSelf.routeDetailWrapperView.isHidden = false
                //
                UIView.animate(withDuration: 0.25) {
                // 添加面板出现动画
                strongSelf.routeDetailWrapperView.frame.origin.y = 400.0
                    
                }
                //TODO: Go to AR mode
            } else {
                let alert = UIAlertController(title: "Cannot find directions!", message: "Please try with another destination, thanks", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                strongSelf.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func goButtonTapped(button: UIButton) {
        searchBar.resignFirstResponder()
        UIView.animate(withDuration: 0.25) {
            //弹到底部
            self.shadowView1.frame.origin.y  = UIScreen.main.bounds.height - 60
        }
        plotARRoute()
    }
    @objc func cancelButtonTapped(button: UIButton) {
        searchBar.resignFirstResponder()
        reset()
        self.routeDetailWrapperView.isHidden = true
    }
        
    
}
extension DispatchQueue {
    func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        self.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: execute)
    }
}

extension UIView {
    func recursiveSubviews() -> [UIView] {
        var recursiveSubviews = self.subviews
        
        for subview in subviews {
            recursiveSubviews.append(contentsOf: subview.recursiveSubviews())
        }
        
        return recursiveSubviews
    }
}
// MARK: - MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
    // -------当地图显示区域改变时调用
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //搜索的范围是地图显示的范围
        localSearchCompleter.region = mapView.region
    }
    // 当添加大头针时调用
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constant.ViewController.AnnotationViewIdentifier) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: Constant.ViewController.AnnotationViewIdentifier)
            // 创建点击的按钮
            let button = UIButton(type: .custom)
            button.frame = CGRect(origin: .zero, size: CGSize(width: 22, height: 22))
            button.setImage(UIImage(named: "direction"), for: .normal)
            button.layer.setValue(annotation, forKey: Constant.ViewController.AnnotationKeyPath)
            button.addTarget(self, action: #selector(directionButtonTapped(_:)), for: .touchUpInside)
            // 大头针的右边添加为这个按钮
            annotationView?.rightCalloutAccessoryView = button
            annotationView?.canShowCallout = true
            annotationView?.animatesWhenAdded = true
        }
        annotationView?.annotation = annotation
        //print(routeDetailWrapperView.frame)
        return annotationView
    }
    // 把导航路线添加到地图中添加
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = MKPinAnnotationView.purplePinColor()
        renderer.lineWidth = 8.0
        return renderer
    }
    // 当大头针杯选择时调用
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        searchBar.resignFirstResponder()
        
    }
    //用户更新时调用
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if i < 2 {
        // 设置地图中心
        mapView.setCenter((userLocation.location?.coordinate)!, animated: false)
        // 设置地图的区域
        self.mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
             i = i + 1
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    
}
//MARK: ---------------------------搜索框的代理 ---------------------------
extension ViewController: UISearchBarDelegate {
        // 当搜索框文字内容改变时调用
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 将搜索内容拿去查询
        searchLocations(searchText: searchText)
    }
         //在文本编辑时调用
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchLocations(searchText: searchBar.text!)
    }
}
//MARK: ---------------------------监听搜索框内容 ---------------------------
extension ViewController: MKLocalSearchCompleterDelegate {
    // 当指定的搜索完成器更新其搜索完成数组时调用
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // 从头开始重装所有东西。重新显示可见行。请注意，这将导致任何现有的放下占位符行被删除。
        tableView.reloadData()
    }
}


//MARK: ---------------------------table内容代理 ---------------------------
extension ViewController: UITableViewDataSource {
    // 设置tableView的组数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 根据搜索返回的条数

        return localSearchCompleter.results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 更新的出队方法保证了单元被正确地返回并调整大小，假设标识符被注册
        //let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifier, for: indexPath)
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: Constant.ViewController.TableViewCellIdentifier)
        // 设置cell的内容
        
        cell.textLabel?.text = localSearchCompleter.results[indexPath.row].title
        cell.detailTextLabel?.text = localSearchCompleter.results[indexPath.row].subtitle
        return cell
    }
}
//MARK: ---------------------------样式代理 ---------------------------
extension ViewController: UITableViewDelegate {

    // 设置tableView的高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    // 设置tableView被选中时所要处理的事件
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reset()
        DispatchQueue(label: "com.levantAJ.ARCL.queue.load-location").async { [weak self] in
            guard let strongSelf = self else { return }
            let completion = strongSelf.localSearchCompleter.results[indexPath.row]
            let request = MKLocalSearchRequest(completion: completion)
            let localSearch = MKLocalSearch(request: request)
            localSearch.start { [weak self] (response, error) in
                guard let response = response else { return }
                DispatchQueue.main.async { [weak self] in
                    for (index, mapItem) in response.mapItems.enumerated() {
                        let annotation = MKPointAnnotation()
                        annotation.title = mapItem.placemark.title
                        annotation.coordinate = mapItem.placemark.coordinate
                        self?.mapView.addAnnotation(annotation)
                        if index == 0 {
                            //设置地图中心
                            self?.mapView.setCenter(annotation.coordinate, animated: true)
                        }
                    }
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        //************** 这可能会出BUG****************
        searchResultsWrapperView.isHidden = true
        searchBar.resignFirstResponder()
        //重新添加触摸事件
        //sceneLocationView.addGestureRecognizer(tapGR)
    }
}
//MARK: ---------------------------拓展 ---------------------------
extension ViewController {
    fileprivate var searchWrapperViewDefaultTopConstant: CGFloat {
        // 界面高度减底部高度
        return shadowView1.bounds.height - Constant.ViewController.BottomPadding
    }
     // 当键盘将要出现时，面板弹到顶部
    @objc func keyboardWillShow() {
        UIView.animate(withDuration: 0.25) {
            self.shadowView1.frame.origin.y = Constant.ViewController.TopPadding
        }
    }
    
    @objc func keyboardWillHide() {
        
    }
    
    fileprivate func reset() {
        // 移除气球
        mapView.removeOverlays(mapView.overlays)
        let annotations = mapView.annotations.filter { !$0.isKind(of: MKUserLocation.self) }
        mapView.removeAnnotations(annotations)
    }
    
    fileprivate func searchLocations(searchText: String) {
        // 当搜索框输入为空时，隐藏tableView
        searchResultsWrapperView.isHidden = searchText.isEmpty
        if(!searchText.isEmpty){
            tableView.becomeFirstResponder()
        }else{
            //暂时不用触摸事件
            //sceneLocationView.removeGestureRecognizer(tapGR)
        }
        // 要查询的内容为搜索框的内容
        localSearchCompleter.queryFragment = searchText
    }
}

struct Constant {}

extension Constant {
    struct ViewController {
        //设置上拉的顶部高度
        static let TopPadding = CGFloat(60)
        //设置底部高度
        static let BottomPadding = CGFloat(60)
        static let AnnotationViewIdentifier = "AnnotationView"
        //static let TableViewCellIdentifier = "TableViewCell"
        static let AnnotationKeyPath = "AnnotationKeyPath"
        // 添加cell注册
        static let TableViewCellIdentifier = "TableViewCellIdentifier"
    }
}

