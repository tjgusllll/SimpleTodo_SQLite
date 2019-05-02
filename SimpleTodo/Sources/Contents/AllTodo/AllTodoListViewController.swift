//
//  AllTodoListViewController.swift
//  SimpleTodo
//
//  Created by 조서현 on 2019. 4. 28..
//  Copyright © 2019년 조서현. All rights reserved.
//

import UIKit
import SnapKit


class AllTodoListViewController: UIViewController, UITextFieldDelegate {

    //MARK:- Constant
    
    struct UI {
        static let basicMargin: CGFloat = 10
        static let titleFontSize: UIFont = UIFont.boldSystemFont(ofSize: 30)
        static let basicFontSize: UIFont = UIFont.systemFont(ofSize: 20)
        static let titleViewHeight: Int = 50
        static let newTextHeight: Int = 30
        
    }
    
    
    //MARK:- UI Properties
    
    var tableview: UITableView = {
        let tableview = UITableView(frame: .zero, style: .plain)
        tableview.register(AllTodoTableViewCell.self, forCellReuseIdentifier: "AllTodo")
        tableview.backgroundColor = .black
        tableview.separatorColor = .black
        return tableview
    }()
    
    let titleView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UI.titleFontSize
        label.text = "Lists"
        return label
    }()
    
    let newTodoText: UITextField = {
        let text = UITextField()
        text.font = UI.basicFontSize
        text.backgroundColor = .black //.black 으로 수정
        text.textColor = .white
        text.attributedPlaceholder = NSAttributedString(string: "Add new list here", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        return text
    }()
    
    var cancleBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancleNew))
        button.tintColor = .white
        return button
    }()
    
    
    
    
    //MARK:- Properties
    var renameId: Int = 0
    let defaults = UserDefaults.standard
    let encoder = JSONEncoder()
    var todos: [AllTodoModel] = []
    
    //MARK:- Setup UI
    func setupUI() {
        
        self.tableview.dataSource = self
        self.tableview.delegate = self
        view.addSubview(titleView)
        view.addSubview(tableview)
        
        titleView.addSubview(titleLabel)
        titleView.addSubview(newTodoText)
        
        self.navigationItem.rightBarButtonItem = nil
        
        self.newTodoText.delegate = self

        
        //Snap Kit
        titleView.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.topMargin)
            make.leading.equalTo(self.view.snp.leading)
            make.trailing.equalTo(self.view.snp.trailing)
            make.height.equalTo(UI.titleViewHeight)
        }
        
        tableview.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom)
            make.leading.equalTo(self.view.snp.leading)
            make.trailing.equalTo(self.view.snp.trailing)
            make.bottom.equalTo(self.view.snp.bottom)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.top).offset(UI.basicMargin)
            make.leading.equalTo(titleView.snp.leading).offset(UI.basicMargin)
        }
        
        newTodoText.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(UI.basicMargin)
            make.leading.equalTo(titleView.snp.leading).offset(UI.basicMargin)
            make.trailing.equalTo(titleView.snp.trailing).offset(-UI.basicMargin)
            make.height.equalTo(UI.newTextHeight)
        }
        
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        //Swipe Down
        setupSlideDown()
        
        //Data idCount Setup
        loadAllTodo()
        
        
        
    }

    
    //MARK:- Slide Down
    func setupSlideDown() {
        let slideDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(slideDownGesture))
        slideDown.direction = .down
        self.tableview.addGestureRecognizer(slideDown)
    }
    
    @objc func slideDownGesture() {
        UIView.animate(withDuration: 3.0) {
            
            self.tableview.snp.removeConstraints()
            self.titleView.snp.updateConstraints { make in
                make.height.equalTo(UI.titleViewHeight*2)
            }
            self.tableview.snp.makeConstraints { make in
                make.top.equalTo(self.titleView.snp.bottom)
                make.leading.equalTo(self.view.snp.leading)
                make.trailing.equalTo(self.view.snp.trailing)
                make.bottom.equalTo(self.view.snp.bottom)
            }
            
            self.titleView.layoutIfNeeded()
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancleNew))//cancleBarButton
    }
    
    
    //cancle BarButton Action
    @objc func cancleNew() {
        self.navigationItem.rightBarButtonItem = nil
        
        UIView.animate(withDuration: 3.0) {
            
            self.tableview.snp.removeConstraints()
            self.titleView.snp.updateConstraints { make in
                make.height.equalTo(UI.titleViewHeight)
            }
            self.tableview.snp.makeConstraints { make in
                make.top.equalTo(self.titleView.snp.bottom)
                make.leading.equalTo(self.view.snp.leading)
                make.trailing.equalTo(self.view.snp.trailing)
                make.bottom.equalTo(self.view.snp.bottom)
            }
            self.reloadData()
            self.titleView.layoutIfNeeded()
        }
    }
    
    
    
    
}


//MARK:- Data Call
extension AllTodoListViewController {
    
    func saveTodo(newTodo: String, lastid: Int?) {
        guard let lastid = lastid else { return }
        let newtodo = AllTodoModel(title: newTodo, id: lastid+1, detailCount: 0)
        self.todos.append(newtodo)
        
        if let encoded = try? encoder.encode(todos) {
            defaults.set(encoded, forKey: "TodoList")
        }
        self.reloadData()
    }

    func loadAllTodo() {
        let decoder = JSONDecoder()
        if let data = defaults.object(forKey: "TodoList") as? Data {
            if let loadedTodo = try? decoder.decode([AllTodoModel].self, from: data) {
                todos = loadedTodo
            }
        }
        print(todos)
    }
    
    //Delete Todo
    func deleteTodo(id: Int) {
        var index: Int = 0
        
        for todo in todos {
            if id == todo.id {
                self.todos.remove(at: index)
                print("delete \(index)")
                if let encoded = try? encoder.encode(todos) {
                    defaults.set(encoded, forKey: "TodoList")
                }
                break
            } else {
                print(index)
                index+=1
            }
        }
        self.reloadData()
    }
    
    //Add newTodo
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newTodoText.resignFirstResponder()
        if renameId == 0 { //add
            var lastid: Int? = 0
            if todos.count != 0 {
                lastid = todos[todos.count-1].id
            }
            
            if let todo = newTodoText.text {
                if todo != "" {
                    self.saveTodo(newTodo: todo, lastid: lastid)
                    newTodoText.text = ""
                }
                cancleNew()
            }
        } else { //rename
            if let renameTodo = newTodoText.text {
                if renameTodo != "" {
                    self.renameTodo(renametodo: renameTodo, id: renameId)
                    newTodoText.text = ""
                }
                cancleNew()
            }
        }
        return true
    }
    
    //Rename Todo
    func renameTodo(renametodo: String, id: Int){
        //todos.title 수정한뒤 reload, todos를 userdefault에 저장
        var index: Int = 0
        
        for todo in todos {
            if id == todo.id {
                self.todos[index].title = renametodo
                if let encoded = try? encoder.encode(todos) {
                    defaults.set(encoded, forKey: "TodoList")
                }
                renameId = 0
                break
            } else {
                print(index)
                index+=1
            }
        }
        self.reloadData()
    }
    
}


//MARK:- TableView
extension AllTodoListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllTodo", for: indexPath) as! AllTodoTableViewCell
        cell.backgroundColor = .black
        
        cell.configureUI(with: todos[indexPath.row])
        return cell
    }
    
    func reloadData() {
        tableview.reloadData()
        print("reloaded \(todos.count)")
    }
    
    
    
    //MARK:- SwipeAction
    
    //Rename leadingSwipeAction
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let renameAction = self.contextualRenameAction(forRowAtIndexPath: indexPath)
        renameAction.backgroundColor = .blue
        let swipeConfig = UISwipeActionsConfiguration(actions: [renameAction])
        return swipeConfig
    }
    
    func contextualRenameAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: "Rename") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            completionHandler(true)
            self.slideDownGesture()
            self.newTodoText.text = self.todos[indexPath.row].title
            if let id = self.todos[indexPath.row].id {
                self.renameId = id
            }
        }
        return action
    }
    
    
    
    //Delete trailingSwipeAction
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
        deleteAction.backgroundColor = .red
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
    }
    
    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        
        let deleteTodoId = todos[indexPath.row].id
        
        let action = UIContextualAction(style: .normal, title: "Delete") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            completionHandler(true)
            if let id = deleteTodoId {
                self.deleteTodo(id: id)
            }
            
        }
        
        return action
    }
    
    
    
}
