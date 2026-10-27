abstract final class RouteNames {
  static const splash = '/';
  static const signIn = '/auth/signin';
  static const signUp = '/auth/signup';

  static const home = '/home';

  static const transactions = '/transactions';
  static const addTransaction = '/transactions/add';
  static const addIncome = '/transactions/add?type=income';
  static const addExpense = '/transactions/add?type=expense';

  static const budgets = '/budgets';
  static const addBudget = '/budgets/add';

  static const savings = '/savings';
  static const addGoal = '/savings/add';

  static const reports = '/reports';

  static const settings = '/settings';
  static const categories = '/settings/categories';

  static String editTransaction(String id) => '/transactions/$id/edit';

  static String editBudget(String id) => '/budgets/$id/edit';

  static String goalDetail(String id) => '/savings/$id';

  static String editGoal(String id) => '/savings/$id/edit';
}
