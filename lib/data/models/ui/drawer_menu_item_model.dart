class DrawerMenuItemModel {
  final String title;
  final String? icon;
  final bool isExpandable;
  final bool isNew;
  final bool isComingSoon;
  final String? route;
  final String? routeArgument;
  final List<DrawerMenuItemModel>? subItems;

  DrawerMenuItemModel({
    required this.title,
    this.icon,
    this.isExpandable = false,
    this.isNew = false,
    this.isComingSoon = false,
    this.route,
    this.routeArgument,
    this.subItems,
  });

  @override
  String toString() {
    return 'DrawerMenuItemModel(title: $title, icon: $icon, isExpandable: $isExpandable, isNew: $isNew, route: $route, routeArgument: $routeArgument, subItems: ${subItems?.map((e) => e.title).toList()})';
  }
}
