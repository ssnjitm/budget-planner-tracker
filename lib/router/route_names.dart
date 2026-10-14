abstract final class RouteNames {
  static const home = '/home';

  static const transactions = '/transactions';
  static const addTransaction = '/transactions/add';

  static const budgets = '/budgets';
  static const addBudget = '/budgets/add';

  static const savings = '/savings';
  static const addGoal = '/savings/add';

  static const reports = '/reports';

  static const settings = '/settings';
  static const accounts = '/settings/accounts';
  static const categories = '/settings/categories';

  static String editTransaction(String id) => '/transactions/$id/edit';

  static String editBudget(String id) => '/budgets/$id/edit';

  static String goalDetail(String id) => '/savings/$id';

  static String editGoal(String id) => '/savings/$id/edit';
}
