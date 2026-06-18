//
//  ProductosListViewController.swift
//  TecStoreManager
//
//  Pantalla UIKit: Lista de Productos — conectada al Main.storyboard
//  Componentes IBOutlet: UISearchBar, UISegmentedControl, UILabel (×2), UITableView
//  Componentes IBAction: filtroStockCambio
//

import UIKit

class ProductosListViewController: UIViewController {

    // MARK: - ViewModel
    private let viewModel = ProductoViewModel()

    // MARK: - IBOutlets (conectados desde el Storyboard)
    @IBOutlet weak var searchBar: UISearchBar!              // UISearchBar
    @IBOutlet weak var stockSegmented: UISegmentedControl!  // UISegmentedControl
    @IBOutlet weak var countLabel: UILabel!                 // UILabel — Contador
    @IBOutlet weak var emptyLabel: UILabel!                 // UILabel — Estado vacío
    @IBOutlet weak var tableView: UITableView!              // UITableView

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Productos"
        setupBackground()
        setupNavBar()
        setupSearchBar()
        setupTableView()
        styleSegmentedControl()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchProductos()
        reloadTableView()
    }

    // MARK: - Setup
    private func setupBackground() {
        view.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.14, alpha: 1.0)
    }

    private func setupNavBar() {
        let addBtn = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle.fill"),
            style: .plain, target: self, action: #selector(goToNuevoProducto)
        )
        addBtn.tintColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
        navigationItem.rightBarButtonItem = addBtn
    }

    private func setupSearchBar() {
        searchBar?.delegate  = self
        searchBar?.barStyle  = .black
        searchBar?.searchBarStyle = .minimal
        searchBar?.tintColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
        if let tf = searchBar?.searchTextField as UITextField? {
            tf.textColor = .white
        }
    }

    private func setupTableView() {
        tableView?.delegate   = self
        tableView?.dataSource = self
        tableView?.backgroundColor    = .clear
        tableView?.separatorColor     = UIColor(white: 1, alpha: 0.08)
        tableView?.register(ProductoTableViewCell.self, forCellReuseIdentifier: "ProductoCell")
    }

    private func styleSegmentedControl() {
        stockSegmented?.selectedSegmentTintColor = UIColor(red: 0.25, green: 0.52, blue: 0.96, alpha: 1.0)
        stockSegmented?.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        stockSegmented?.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }

    // MARK: - Reload
    private func reloadTableView() {
        countLabel?.text = "\(viewModel.productosFiltrados.count) productos"
        emptyLabel?.isHidden = !viewModel.productosFiltrados.isEmpty
        tableView?.reloadData()
    }

    // MARK: - IBAction
    @IBAction func filtroStockCambio(_ sender: UISegmentedControl) {
        viewModel.filtroStock = ProductoViewModel.FiltroStock.allCases[sender.selectedSegmentIndex]
        reloadTableView()
    }

    // MARK: - Navigation
    @objc private func goToNuevoProducto() {
        let formVC = ProductoFormViewController(viewModel: viewModel, producto: nil)
        formVC.onSave = { [weak self] in
            self?.viewModel.fetchProductos()
            self?.reloadTableView()
        }
        let nav = UINavigationController(rootViewController: formVC)
        present(nav, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ProductosListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.productosFiltrados.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductoCell", for: indexPath) as! ProductoTableViewCell
        cell.configure(with: viewModel.productosFiltrados[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let producto = viewModel.productosFiltrados[indexPath.row]
        let alert = UIAlertController(
            title: "Eliminar Producto",
            message: "¿Deseas eliminar '\(producto.nombreSafe)'?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Eliminar", style: .destructive) { [weak self] _ in
            self?.viewModel.eliminarProducto(producto)
            self?.reloadTableView()
        })
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension ProductosListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 80 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let producto  = viewModel.productosFiltrados[indexPath.row]
        let detalleVC = ProductoDetalleViewController(producto: producto, viewModel: viewModel)
        navigationController?.pushViewController(detalleVC, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension ProductosListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
        reloadTableView()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
