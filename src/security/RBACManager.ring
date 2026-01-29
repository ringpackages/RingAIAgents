/*
Class: RBACManager
Description: Manager for access control based on roles
*/
class RBACManager {
    

    func init {
        oConfig = new SecurityConfig
        loadRoles()
    }

    # Load roles from configuration 
    func loadRoles {
        for role in oConfig.aRoles {
            addRole(role[1], role[2][:permissions], role[2][:level])
        }
    }

    # Add new role
    func addRole cRole, aPermissions, nLevel {
        aUserRoles + [cRole, nLevel]
        aRolePermissions + [cRole, aPermissions]
    }

    # Add permission to role
    func addPermissionToRole cRole, cPermission {
        for i = 1 to len(aRolePermissions) {
            if aRolePermissions[i][1] = cRole {
                aRolePermissions[i][2] + cPermission
                return true
            }
        }
        return false
    }

    # Check user permission
    func checkPermission cUser, cPermission {
        cRole = getUserRole(cUser)
        if cRole = "" return false ok
        
        for role in aRolePermissions {
            if role[1] = cRole {
                return find(role[2], cPermission) > 0
            }
        }
        return false
    }

    # Get user level
    func getUserLevel cUser {
        cRole = getUserRole(cUser)
        for role in aUserRoles {
            if role[1] = cRole {
                return role[2]
            }
        }
        return 0
    }

    private
    
    oConfig
    aUserRoles = []
    aRolePermissions = []

    # Get user role
    func getUserRole cUser {
        # Should implement database connection
            
        return "user"  # temporary
    }
    
}

/*
Class: Permission
Description: Permission object
*/
class Permission {
    cName
    cDescription
    cResource
    cAction

    func init cN, cD, cR, cA {
        cName = cN
        cDescription = cD
        cResource = cR
        cAction = cA
    }

    func toString {
        return cName + ":" + cResource + ":" + cAction
    }
}

/*
Class: Role
Description: Role object
*/
class Role {
    cName
    cDescription
    nLevel
    aPermissions

    func init cN, cD, nL {
        cName = cN
        cDescription = cD
        nLevel = nL
        aPermissions = []
    }

    func addPermission oPermission {
        aPermissions + oPermission
    }

    func hasPermission cPermission {
        for perm in aPermissions {
            if perm.toString() = cPermission {
                return true
            }
        }
        return false
    }
}
