import Foundation

protocol DrawerViewDelegate: AnyObject {
    func didStartDraw(view: DrawerView)
    func didEndDraw(view: DrawerView)
}
