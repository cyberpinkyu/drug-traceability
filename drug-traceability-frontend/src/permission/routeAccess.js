export const ROUTE_ACCESS = {
  '/home/user': ['super_admin', 'admin'],
  '/home/role': ['super_admin', 'admin'],
  '/home/drug': ['super_admin', 'admin', 'regulator', 'producer', 'distributor', 'hospital', 'public'],
  '/home/production': ['super_admin', 'admin', 'producer'],
  '/home/procurement': ['super_admin', 'admin', 'distributor', 'hospital'],
  '/home/sale': ['super_admin', 'admin', 'producer', 'distributor', 'hospital'],
  '/home/inventory': ['super_admin', 'admin', 'producer', 'distributor', 'hospital'],
  '/home/enforcement': ['super_admin', 'admin', 'regulator'],
  '/home/stats': ['super_admin', 'admin', 'regulator'],
  '/home/trace-graph': ['super_admin', 'admin', 'regulator'],
  '/home/report-center': ['super_admin', 'admin', 'regulator'],
  '/home/message-center': ['super_admin', 'admin', 'regulator'],
  '/home/scan-enhance': ['super_admin', 'admin', 'regulator'],
  '/home/data-exchange': ['super_admin', 'admin', 'regulator'],
  '/home/ai': ['super_admin', 'admin', 'regulator', 'producer', 'distributor', 'hospital', 'public']
}

export const HOME_ROUTE_PRIORITY = [
  '/home/stats',
  '/home/enforcement',
  '/home/drug',
  '/home/production',
  '/home/procurement',
  '/home/sale',
  '/home/inventory',
  '/home/ai'
]

export function hasRouteAccess(roleCode, path) {
  const roles = ROUTE_ACCESS[path]
  if (!roles || !roleCode) return false
  return roles.includes(roleCode)
}

export function getHomeLandingPath(roleCode) {
  for (const path of HOME_ROUTE_PRIORITY) {
    if (hasRouteAccess(roleCode, path)) {
      return path
    }
  }
  return '/login'
}
