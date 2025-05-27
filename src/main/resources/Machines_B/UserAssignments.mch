		

MACHINE
    UserAssignments  
SEES
    ContextMachine
DEFINITIONS

    assignedUsers(role)=={uu|uu:USERS & role:roleOf(uu)};
    assignedUsersOfRoleSet(roleSet)==union({uu| uu:POW(USERS) & !rr.(rr:ROLES & rr:roleSet => uu <:assignedUsers(rr)) } );
    /*INTER(rr).{rr:roleSet | assignedUsers(rr)} ;*/
    allAssignedUsers(role)=={uu|uu:USERS & 
        ({role}\/getSubRoles( {role})) /\roleOf(uu)/={}};
	getSubRoles(roleSet)==closure1(Roles_Hierarchy~)[roleSet];
	 
	authorizedUsers(roleSet)== assignedUsersOfRoleSet(getSubRoles(roleSet)\/roleSet);

	getSuperRoles(roleSet)==closure1(Roles_Hierarchy)[roleSet];
	allAssignedRoles(user)==getSuperRoles(roleOf(user))\/roleOf(user)

SETS
    ROLES = {ATM,AccountManager,CustomerUser}
    
    
VARIABLES
    roleOf,    
    Roles_Hierarchy,
    currentUser,
    SSD_mutex,
    DSD_mutex,
    Session
    
INVARIANT
    Roles_Hierarchy : ROLES <-> ROLES &
    roleOf : USERS --> POW(ROLES) &  
    closure1(Roles_Hierarchy) /\ id(ROLES) = {} &    
    currentUser : USERS 

	& Session : USERS<-> ROLES
	& !(uu).(uu:USERS & uu:dom(Session)=> Session[{uu}]<:roleOf(uu))


    & SSD_mutex : POW1(ROLES)<->NAT1 /*card(RoleSet)>= n >=2*/
    & !nn.(nn:NAT1 & nn:ran(SSD_mutex) => nn>=2)
	& !rs.(rs:POW1(ROLES) & rs:dom(SSD_mutex) => card(rs)>=SSD_mutex(rs))
	/*SSD_mutex check*/
	
	& !uu.(uu:USERS & uu:dom(roleOf) => 
	     !rs.(rs:POW1(ROLES) & rs:dom(SSD_mutex) =>  
				card(( closure1(Roles_Hierarchy)[roleOf(uu)]\/roleOf(uu) /\ rs)) < SSD_mutex(rs)
				)
)

	& DSD_mutex :POW1(ROLES)<->NAT1 
	 & !nn.(nn:NAT1 & nn:ran(DSD_mutex) => nn>=2)
	& !rs.(rs:POW1(ROLES) & rs:dom(DSD_mutex) => card(rs)>=DSD_mutex(rs))
	& !uu.(uu:USERS & uu:dom(Session) => 
	     !rs.(rs:POW1(ROLES) & rs:dom(DSD_mutex) =>  
				card(( closure1(Roles_Hierarchy)[Session[{uu}]]\/Session[{uu}] /\ rs)) < DSD_mutex(rs)
				)
)
				
INITIALISATION
    roleOf := {(aATM|->{ATM}),(Martin|->{CustomerUser}),(Paul|->{CustomerUser}),(Bob|->{CustomerUser,AccountManager}),(none |-> {})} ||
    Roles_Hierarchy := {} 
    ||
    currentUser := none 

|| Session:={}/*(Jack|-> Operator),(Jack|-> Team_Doctor)}*/

		||SSD_mutex :={}
		||DSD_mutex :={({AccountManager,CustomerUser}|->2)}
OPERATIONS
  
  /*  
    result<--authorizedUser(roleSet)=
    PRE
        roleSet:ROLES & roleSet=Team_Member
    THEN
           result := authorizedUsers({roleSet})
        
	END;
	*/
	
	
	addRole(user,role) = 
    PRE
        user : USERS
		& role:ROLES & role/:(roleOf(user)\/getSuperRoles(roleOf(user)))  
    THEN
        roleOf := ({user}<<|roleOf) \/{(user|-> ({role} \/ roleOf(user)) ) }
    END;
    

	addRoleSafe(user,role) = 
    PRE
        user : USERS
		& role:ROLES & role/:(roleOf(user)\/getSuperRoles(roleOf(user)))   
		&!rs.(rs:POW1(ROLES) & rs:dom(SSD_mutex) =>  
				card(( (closure1(Roles_Hierarchy)[roleOf(user)\/{role}]\/roleOf(user)\/{role}) /\ rs)) < SSD_mutex(rs)
				)
    THEN
        roleOf := ({user}<<|roleOf) \/{(user|-> ({role} \/ roleOf(user)) ) }
    END;


	removeRole(user,role) = 
    PRE
        user : USERS
		& role:ROLES & role:roleOf(user)  
		& role/:ran(Session)
    THEN
        roleOf := ({user}<<|roleOf) \/{(user|-> (roleOf(user)-{role}) ) }
    END;
    
    
   setCurrentUser(user) = 
    PRE
        user : USERS & user /= currentUser 
        & user : dom(Session) 
    THEN
        currentUser := user
    END ;


  connect(user,roleSet) = 
    PRE
        user : USERS & user/:dom(Session) 
		& roleSet:POW1(ROLES) & roleSet<:roleOf(user)  
    THEN
        Session := Session\/({user}*roleSet)
    END;
	

safeConnect(user,roleSet) = 
    PRE
        user : USERS & user/:dom(Session) 
        & roleSet : POW1(ROLES) & roleSet <: roleOf(user)  
        /*avoid hierarchical redundancy in the roleSet*/
        & !(r1,r2).(r1 : roleSet & r2 : roleSet & r1 /= r2 
            =>  r2 /: closure1(Roles_Hierarchy)[{r1}])
        /*avoid DSD violation*/
        & !rs.(rs:POW1(ROLES) & rs:dom(DSD_mutex) =>  
		card(( closure1(Roles_Hierarchy)[roleSet]\/roleSet /\ rs)) < DSD_mutex(rs)
			)
    THEN
        Session := Session \/ ({user}*roleSet)
    END;
  

	disconnect(user) = 
    PRE
        user : USERS & user:dom(Session)  
    THEN
        Session := {user}<<|Session
    END


END

 
	