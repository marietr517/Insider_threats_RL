		
MACHINE
    RBAC_Model
INCLUDES
    Functional,
    UserAssignments
PROMOTES
LaunchAttack

SEES
	ContextMachine

SETS
    ENTITIES = {
    Account_Label,Customer_Label,CreditCard_Label};
    Attributes = {Account_balance_Label,Account_overdraft_Label,Account_IBAN_Label,Customer_name_Label,Customer_address_Label,CreditCard_inLine_Label
    };

    Operations = {
    Account__depositFunds_Label
    ,Account__transferFunds_Label
    ,Account__withdrawCash_Label
    ,CreditCard__activate_Label
    ,CreditCard__deactivate_Label
    ,Account_NEW_Label
    ,Customer_NEW_Label
    ,CreditCard_NEW_Label
    ,Account_Free_Label
    ,Customer_Free_Label
    ,CreditCard_Free_Label
    ,Account__GetAccountOwner_Label
    ,Customer__GetAccountOwner_Label
    ,CreditCard__GetCreditCardOwner_Label
    ,Customer__GetCreditCardOwner_Label
    ,Account__SetAccountOwner_Label
    ,CreditCard__SetCreditCardOwner_Label
    ,Customer__SetCreditCardOwner_Label
    ,Customer__AddAccountOwner_Label
    ,Customer__RemoveAccountOwner_Label
    ,Account__GetBalance_Label
    ,Account__GetOverdraft_Label
    ,Account__GetIBAN_Label
    ,Customer__GetName_Label
    ,Customer__GetAddress_Label
    ,CreditCard__GetInLine_Label
    ,Account__SetBalance_Label
    ,Account__SetOverdraft_Label
    ,Customer__SetName_Label
    ,Customer__SetAddress_Label
    ,CreditCard__SetInLine_Label
    ,Account__SetIBAN_Label
    
    
};
	KindsOfAtt = {public, private};    
    PERMISSIONS = {AccountManagerPerm2,CustomerUserPerm2,AccountManagerPerm1,ATMPerm,CustomerUserPerm1};        
	ActionsType = {read, create, modify, delete, privateRead, privateModify,fullAccess};
	Stereotypes = {readOp, modifyOp};
	AssociationRole = {not_yet_implemented}

DEFINITIONS   
GOAL== (
Customer = {Paul,Martin,Bob}&
			Account = {cpt1,cpt2,cpt3,cpt4} &
			AccountOwner = {(cpt1|->Bob),(cpt2|->Martin),(cpt3|->Paul),(cpt4|->Bob)}&
			Account__IBAN = {(cpt1|->-100),(cpt2|->222),(cpt3|->333),(cpt4|->444)}&
			Account__overdraft = {(cpt1|->-100),(cpt2|->-100),(cpt3|->-100),(cpt4|->-100)}&
 			Account__balance = {(cpt1|->300),(cpt2|->-100),(cpt3|->0),(cpt4|->0)});
  CUSTOMER == USERS - {none, aATM}; 
 
/*Transformee de relation de EntityActions*/
	allEntityActions == {pp, at | pp : PERMISSIONS & at : ActionsType 
    					& pp : dom(EntityActions) & at : EntityActions(pp)} ;

/* Les roles ayant des des droits de creation : renvoit des couples (role, entite)*/
    PermEntitiesCreation == ran({create,fullAccess} <| (allEntityActions~ ; PermissionAssignement)) ;
    /*les operations de creation permises : renvoit des couples (role, constructeur)*/ 
    PermOpCreation == (PermEntitiesCreation ; constructorOf~);
    
/* Les roles ayant des des droits de detruction : renvoit des couples (role, entite)*/
    PermEntitiesDestruction == ran({delete,fullAccess} <| (allEntityActions~ ; PermissionAssignement)) ;
    /*les operations de destruction permises : renvoit des couples (role, destructeur)*/ 
    PermOpDestruction == (PermEntitiesDestruction ; destructorOf~);
    
	/* Les roles ayant des des droits de lecture : renvoit des couples (role, entite)*/
    PermEntitiesPRead == ran({privateRead,fullAccess} <| (allEntityActions~ ; PermissionAssignement)) ;
    /*les operations de lecture permises : renvoit des couples (role, getterprive)*/ 
    PermOpPRead == (PermEntitiesPRead ; (getterOf ; AttributeOf)~)  ;
    
    /*getters des attribus publics*/
    publicGetters == getterOf |> dom(AttributeKind |> {public});
    /* Les roles ayant des des droits de lecture : renvoit des couples (role, entite)*/
    PermEntitiesRead == ran({read,fullAccess} <| (allEntityActions~ ; PermissionAssignement)) ;
    /*les operations de lecture permises : renvoit des couples (role, getter public)*/ 
    PermOpRead == (PermEntitiesRead ; (publicGetters ; AttributeOf)~) ;
    
    /*Permissions sur les operations de modification*/
    PermEntitiesPModify == ran({privateModify,fullAccess} <| (allEntityActions~ ; PermissionAssignement)) ;
    PermOpPModify == (PermEntitiesPModify ; (setterOf ; AttributeOf)~) ;
    
    publicSetters == setterOf |> dom(AttributeKind |> {public});
    PermEntitiesModify == ran({modify,fullAccess} <| (allEntityActions~ ; PermissionAssignement)) ;
    PermOpModify == (PermEntitiesModify ; (publicSetters ; AttributeOf)~) ;

	PermEntitiesAbsoluteRead == ran({privateRead, read,fullAccess} <| (allEntityActions~ ; PermissionAssignement)) ;
	PermEntitiesAbsoluteModify == ran({privateModify, modify,fullAccess} <| (allEntityActions~ ; PermissionAssignement)) ;
	PermOpReadOps == (PermEntitiesAbsoluteRead ; (StereotypeOps[{readOp}] <| OperationOf)~)  ;
	PermOpModifyOps == (PermEntitiesAbsoluteModify ; (StereotypeOps[{modifyOp}] <| OperationOf)~)  ;
	
	    PermOpMethodAction== {ro, op |ro: ROLES &  op <: Operations & op :ran(MethodActions) & ro : dom((MethodActions~ ; PermissionAssignement)[{op}]) }   ;     
	    
	    PermOpMethodActions == {ro, op | ro : ROLES & op : Operations & op : union(PermOpMethodAction[{ro}])} ;
	    
    /*classRoles perms*/
    PermOpAssoRoleRead == (PermEntitiesRead ; (AssoRoleAccessorOf ; AssoRoleOf)~) ;
	PermOpAssoRoleModify == (PermEntitiesModify ; (AssoRoleMutatorOf ; AssoRoleOf)~) ;
    /**/
    
    
    
	/*currentRole == (roleOf(currentUser) \/ ran(roleOf(currentUser)<|closure1(Roles_Hierarchy))) ;*/	    
	currentRole == (Session[{currentUser}] \/ ran(Session[{currentUser}]<|closure1(Roles_Hierarchy))) ;
	
	permissions == PermOpCreation \/
				   PermOpDestruction \/ 
	        	   PermOpPRead \/ 
				   PermOpReadOps \/ 
	        	   PermOpRead \/       	   
	        	   PermOpPModify \/ 
				   PermOpModifyOps \/ 
				   PermOpModify \/
				   PermOpMethodActions
				   \/PermOpAssoRoleRead
				   \/PermOpAssoRoleModify
    
 
VARIABLES
    AttributeKind, AttributeOf, OperationOf, 
    constructorOf, destructorOf, setterOf, getterOf, 
    AssoRoleOf,AssoRoleAccessorOf,AssoRoleMutatorOf,
    PermissionAssignement, 
    EntityActions,
	MethodActions,
    StereotypeOps,
    isPermitted,
attack
INVARIANT
    /*Function model Elements*/
	AttributeKind : Attributes --> KindsOfAtt &
	AttributeOf : Attributes --> ENTITIES &
	OperationOf : Operations --> ENTITIES &
	constructorOf : Operations >+> ENTITIES &
	destructorOf : Operations >+> ENTITIES &
	setterOf : Operations >+> Attributes &
	getterOf : Operations >+> Attributes &
	StereotypeOps :  Stereotypes <-> Operations &

	setterOf /\ getterOf = {} &
	
	/*---ClassRoles*/
	
	AssoRoleOf : AssociationRole +-> ENTITIES &
	AssoRoleAccessorOf : Operations <-> AssociationRole &
	AssoRoleMutatorOf : Operations <-> AssociationRole &
	
	
	
	/* Access Control Elements */
	
	PermissionAssignement : PERMISSIONS --> (ROLES * ENTITIES) &
	EntityActions : PERMISSIONS +-> POW(ActionsType) &
	MethodActions : PERMISSIONS +-> POW(Operations) &
	/* ! (pp | pp : PERMISSIONS => MethodActions(pp) <: OperationOf~[ran(PermissionAssignement(pp))] ) & */
	isPermitted : ROLES <-> Operations &
	attack : BOOL & attack = FALSE  /*&

        cpt1 /: AccountOwner~[{Bob}]*/
	
   
INITIALISATION
    AttributeKind := {(Account_balance_Label|->public),(Account_overdraft_Label|->public),(Account_IBAN_Label|->public),(Customer_name_Label|->public),(Customer_address_Label|->public),(CreditCard_inLine_Label|->public)}
    ||
    AttributeOf := {(Account_balance_Label|->Account_Label),(Account_overdraft_Label|->Account_Label),(Account_IBAN_Label|->Account_Label),(Customer_name_Label|->Customer_Label),(Customer_address_Label|->Customer_Label),(CreditCard_inLine_Label|->CreditCard_Label)}
    ||
    
    OperationOf := {
    (Account__depositFunds_Label|->Account_Label)
    ,(Account__transferFunds_Label|->Account_Label)
    ,(Account__withdrawCash_Label|->Account_Label)
    ,(CreditCard__activate_Label|->CreditCard_Label)
    ,(CreditCard__deactivate_Label|->CreditCard_Label)
    ,(Account_NEW_Label|->Account_Label)
    ,(Customer_NEW_Label|->Customer_Label)
    ,(CreditCard_NEW_Label|->CreditCard_Label)
    ,(Account_Free_Label|->Account_Label)
    ,(Customer_Free_Label|->Customer_Label)
    ,(CreditCard_Free_Label|->CreditCard_Label)
    ,(Account__GetAccountOwner_Label|->Account_Label)
    ,(Customer__GetAccountOwner_Label|->Customer_Label)
    ,(CreditCard__GetCreditCardOwner_Label|->CreditCard_Label)
    ,(Customer__GetCreditCardOwner_Label|->Customer_Label)
    ,(Account__SetAccountOwner_Label|->Account_Label)
    ,(CreditCard__SetCreditCardOwner_Label|->CreditCard_Label)
    ,(Customer__SetCreditCardOwner_Label|->Customer_Label)
    ,(Customer__AddAccountOwner_Label|->Customer_Label)
    ,(Customer__RemoveAccountOwner_Label|->Customer_Label)
    ,(Account__GetBalance_Label|->Account_Label)
    ,(Account__GetOverdraft_Label|->Account_Label)
    ,(Account__GetIBAN_Label|->Account_Label)
    ,(Customer__GetName_Label|->Customer_Label)
    ,(Customer__GetAddress_Label|->Customer_Label)
    ,(CreditCard__GetInLine_Label|->CreditCard_Label)
    ,(Account__SetBalance_Label|->Account_Label)
    ,(Account__SetOverdraft_Label|->Account_Label)
    ,(Customer__SetName_Label|->Customer_Label)
    ,(Customer__SetAddress_Label|->Customer_Label)
    ,(CreditCard__SetInLine_Label|->CreditCard_Label)
    ,(Account__SetIBAN_Label|->Account_Label)
    
   
     
  
    }
    ||
    constructorOf := {(Account_NEW_Label|->Account_Label),(Customer_NEW_Label|->Customer_Label),(CreditCard_NEW_Label|->CreditCard_Label)
    
    }
    ||
    destructorOf := {(Account_Free_Label|->Account_Label),(Customer_Free_Label|->Customer_Label),(CreditCard_Free_Label|->CreditCard_Label)}
    ||
    StereotypeOps := {(modifyOp|->Account__transferFunds_Label)
    ,(modifyOp|->Account__withdrawCash_Label)
    ,(modifyOp|->CreditCard__activate_Label)
    ,(modifyOp|->CreditCard__deactivate_Label)
    }
    ||
    setterOf := {(Account__SetBalance_Label|->Account_balance_Label),(Account__SetOverdraft_Label|->Account_overdraft_Label),(Customer__SetName_Label|->Customer_name_Label),(Customer__SetAddress_Label|->Customer_address_Label),(CreditCard__SetInLine_Label|->CreditCard_inLine_Label),(Account__SetIBAN_Label|->Account_IBAN_Label)}
    ||
    getterOf := {(Account__GetBalance_Label|->Account_balance_Label),(Account__GetOverdraft_Label|->Account_overdraft_Label),(Account__GetIBAN_Label|->Account_IBAN_Label),(Customer__GetName_Label|->Customer_name_Label),(Customer__GetAddress_Label|->Customer_address_Label),(CreditCard__GetInLine_Label|->CreditCard_inLine_Label)}    
    ||    
    PermissionAssignement := {(AccountManagerPerm2|->(AccountManager|->Account_Label)),(CustomerUserPerm2|->(CustomerUser|->Account_Label)),(AccountManagerPerm1|->(AccountManager|->Customer_Label)),(ATMPerm|->(ATM|->CreditCard_Label)),(CustomerUserPerm1|->(CustomerUser|->Customer_Label))}
    ||
  

    EntityActions := {(AccountManagerPerm2|->{create}),(CustomerUserPerm2|->{read}),(AccountManagerPerm1|->{fullAccess}),(ATMPerm|->{}),(CustomerUserPerm1|->{read})}
   	||
   	MethodActions := {(AccountManagerPerm2|->{}),(CustomerUserPerm2|->{Account__transferFunds_Label,Account__withdrawCash_Label,Account__depositFunds_Label}),(AccountManagerPerm1|->{Customer_Free_Label,Customer__GetAccountOwner_Label,Customer__GetCreditCardOwner_Label, Customer__SetCreditCardOwner_Label, Customer__AddAccountOwner_Label, Customer__RemoveAccountOwner_Label, Customer__GetName_Label, Customer__GetAddress_Label, Customer__SetName_Label, Customer__SetAddress_Label}),(ATMPerm|->{CreditCard__activate_Label,CreditCard__deactivate_Label}),(CustomerUserPerm1|->{})}
	
	
	    	|| AssoRoleOf:={}

		|| AssoRoleAccessorOf:={}


|| AssoRoleMutatorOf:={}
	
	
	
	||
   	isPermitted := {}
|| attack := FALSE
OPERATIONS


malicious <-- checkMaliciousState = 			PRE cpt1 : AccountOwner~[{Bob}] THEN
						malicious := TRUE
					END;

setPermissions = PRE isPermitted = {} THEN 
			isPermitted := permissions ||
			InitiateAttack
		END;
/*
secure_LaunchAttack =
PRE
   isPermitted /= {}  
THEN
   LaunchAttack
END;
*/

secure_InitiateAttack =
PRE
   isPermitted /= {} 
THEN
   InitiateAttack
END;


secure_Account__depositFunds(Instance, m) =
PRE
    Instance : Account & m : NATURAL1
    &    AccountOwner[{Instance}] /= {}
THEN 		
        SELECT 
	   Account__depositFunds_Label : isPermitted[currentRole] &
	   AccountOwner(Instance) = currentUser 	        
	THEN
	   Account__depositFunds(Instance, m)
	END
END ;


secure_Account__transferFunds(Instance, NB, m)=
PRE
    Instance : Account & NB : NAT 	& m : NATURAL1
    &    AccountOwner[{Instance}] /= {}
    &    NB : ran({Instance} <<| Account__IBAN)
    &    AccountOwner[{Account__IBAN~(NB)}] /= {}
    &    Account__balance(Instance) - m >= Account__overdraft(Instance)	
THEN 		
	    SELECT 
	        Account__transferFunds_Label : isPermitted[currentRole] &
	        AccountOwner(Instance) = currentUser 
	        
	    THEN
		IF
	 	   currentUser = Bob &
	 	   Instance = cpt1 &
	 	   AccountOwner[{Account__IBAN~(NB)}] = {Bob}
		THEN
	 	   	   attack := TRUE ||
	           Account__transferFunds(Instance,NB,m)
	    	END
	     END
END
;


secure_Account__withdrawCash(Instance, m)=
   PRE
    Instance : Account 	&	m : NATURAL1
    &    AccountOwner[{Instance}] /= {}
    &    Account__balance(Instance) - m >= Account__overdraft(Instance)
    &    CreditCardOwner~[{AccountOwner(Instance)}] /= {}
    &    CreditCard__inLine(CreditCardOwner~(AccountOwner(Instance))) = TRUE	
	THEN 		SELECT 
	        Account__withdrawCash_Label : isPermitted[currentRole] &
	        AccountOwner(Instance) = currentUser
	    THEN
	        Account__withdrawCash(Instance,m)
	    END
	END
;


secure_CreditCard__activate(Instance)=
	PRE
	Instance : CreditCard 	
	THEN 		SELECT 
	        CreditCard__activate_Label : isPermitted[currentRole]
	    THEN
	        CreditCard__activate(Instance)
	    END
	END
;


secure_CreditCard__deactivate(Instance)=
	PRE
	Instance : CreditCard 	
	THEN 		SELECT 
	        CreditCard__deactivate_Label : isPermitted[currentRole]
	    THEN
	        CreditCard__deactivate(Instance)
	    END
	END
;


secure_Account_NEW(Instance, Account__IBANValue)=
	PRE
	Instance : ACCOUNT 	
	&	Instance /: Account 
	&	Account__IBANValue : NAT 	
	&	Account__IBANValue /: ran(Account__IBAN)
	
	THEN 		SELECT 
	        Account_NEW_Label : isPermitted[currentRole]
	    THEN
	        Account_NEW(Instance, Account__IBANValue)
	    END
	END
;


secure_Customer_NEW(Instance,AccountOwner__accountValues)=
	PRE
	Instance : CUSTOMER 	&	Instance /: Customer 	&	AccountOwner__accountValues : POW(Account) 	&	AccountOwner__accountValues/={}
 & AccountOwner[AccountOwner__accountValues]={} 	
	THEN 		SELECT 
	        Customer_NEW_Label : isPermitted[currentRole]
	    THEN
	        Customer_NEW(Instance,AccountOwner__accountValues)
	    END
	END
;


secure_CreditCard_NEW(Instance,CreditCardOwner__customerValue)=
	PRE
	Instance : CREDITCARD 	&	Instance /: CreditCard 	&	CreditCardOwner__customerValue : Customer 	&	CreditCardOwner__customerValue/:ran(CreditCardOwner) 	
	THEN 		SELECT 
	        CreditCard_NEW_Label : isPermitted[currentRole]
	    THEN
	        CreditCard_NEW(Instance,CreditCardOwner__customerValue)
	    END
	END
;


secure_Account_Free(Instance)=
	PRE
	Instance : ACCOUNT 	&	Instance : Account 	&	 !c2.(c2:AccountOwner[{Instance}] =>#cc.(cc:AccountOwner~[{c2}] & cc/=Instance) ) 	
	THEN 		SELECT 
	        Account_Free_Label : isPermitted[currentRole]
	    THEN
	        Account_Free(Instance)
	    END
	END
;


/*secure_Customer_Free(Instance)=
	PRE
	Instance : CUSTOMER 	&	Instance : Customer 	&	CreditCardOwner~[{Instance}]={} 	& Account__balance(AccountOwner~(Instance)) = 0
	
	THEN 		SELECT 
	        Customer_Free_Label : isPermitted[currentRole]
	    THEN
	        Customer_Free(Instance)
	    END
	END
;*/


secure_CreditCard_Free(Instance)=
	PRE
	Instance : CREDITCARD 	&	Instance : CreditCard 	
	THEN 		SELECT 
	        CreditCard_Free_Label : isPermitted[currentRole]
	    THEN
	        CreditCard_Free(Instance)
	    END
	END
;


result <-- secure_Account__GetAccountOwner(Instance)=
	PRE
	Instance : Account 	&	Instance : dom(AccountOwner) 	
	THEN 		SELECT 
	        Account__GetAccountOwner_Label : isPermitted[currentRole] &
	        (AccountManager : currentRole or AccountOwner(Instance) = currentUser)
	    THEN
	        result <-- 	        Account__GetAccountOwner(Instance)
	    END
	END
;


result <-- secure_Customer__GetAccountOwner(Instance)=
	PRE
	Instance : Customer 	&	Instance : ran(AccountOwner) 	
	THEN 		SELECT 
	        Customer__GetAccountOwner_Label : isPermitted[currentRole] &
	        (AccountManager : currentRole or Instance = currentUser)
	    THEN
	        result <-- 	        Customer__GetAccountOwner(Instance)
	    END
	END
;


result <-- secure_CreditCard__GetCreditCardOwner(Instance)=
	PRE
	Instance : CreditCard 	&	Instance : dom(CreditCardOwner) 	
	THEN 		SELECT 
	        CreditCard__GetCreditCardOwner_Label : isPermitted[currentRole]
	    THEN
	        result <-- 	        CreditCard__GetCreditCardOwner(Instance)
	    END
	END
;


result <-- secure_Customer__GetCreditCardOwner(Instance)=
	PRE
	Instance : Customer 	&	Instance : ran(CreditCardOwner) 	
	THEN 		SELECT 
	        Customer__GetCreditCardOwner_Label : isPermitted[currentRole] &
	        (AccountManager : currentRole or Instance = currentUser)
	    THEN
	        result <-- 	        Customer__GetCreditCardOwner(Instance)
	    END
	END
;


secure_Account__SetAccountOwner(Instance,AccountOwner__customerValue)=
	PRE
	Instance : Account 	&	AccountOwner__customerValue : Customer 	&	(Instance|-> AccountOwner__customerValue) /: AccountOwner 	&	#cc.(cc: Account & cc/=Instance & cc: AccountOwner~[AccountOwner[{Instance}]]) 	
	THEN 		SELECT 
	        Account__SetAccountOwner_Label : isPermitted[currentRole]
	    THEN
	        Account__SetAccountOwner(Instance,AccountOwner__customerValue)
	    END
	END
;


secure_CreditCard__SetCreditCardOwner(Instance,CreditCardOwner__customerValue)=
	PRE
	Instance : CreditCard 	&	CreditCardOwner__customerValue : Customer 	&	(Instance|-> CreditCardOwner__customerValue) /: CreditCardOwner 	&	CreditCardOwner__customerValue/:ran(CreditCardOwner) 	
	THEN 		SELECT 
	        CreditCard__SetCreditCardOwner_Label : isPermitted[currentRole]
	    THEN
	        CreditCard__SetCreditCardOwner(Instance,CreditCardOwner__customerValue)
	    END
	END
;


secure_Customer__SetCreditCardOwner(Instance,CreditCardOwner__creditCardValue)=
	PRE
	Instance : Customer 	&	CreditCardOwner__creditCardValue : CreditCard 	&	(CreditCardOwner__creditCardValue|-> Instance) /: CreditCardOwner 	&	CreditCardOwner__creditCardValue/:dom(CreditCardOwner) 	&	#cc.(cc: Customer & cc/=Instance & cc: CreditCardOwner[CreditCardOwner~[{Instance}]]) 	
	THEN 		SELECT 
	        Customer__SetCreditCardOwner_Label : isPermitted[currentRole]
	    THEN
	        Customer__SetCreditCardOwner(Instance,CreditCardOwner__creditCardValue)
	    END
	END
;


secure_Customer__AddAccountOwner(Instance, AccountOwner__accountValues)=
	PRE
	Instance : Customer 	&	
	AccountOwner__accountValues : Account 	&	
	(AccountOwner__accountValues|-> Instance) /:AccountOwner 	&	
	AccountOwner__accountValues/:dom(AccountOwner)	
	THEN 		SELECT 
	        Customer__AddAccountOwner_Label : isPermitted[currentRole]
	    THEN
	        Customer__AddAccountOwner(Instance,AccountOwner__accountValues)
	    END
	END
;


secure_Customer__RemoveAccountOwner(Instance,AccountOwner__accountValues)=
	PRE
	Instance : Customer 	
&	AccountOwner__accountValues : Account 	
&	(AccountOwner__accountValues|-> Instance) :AccountOwner 	
&	#cc.(cc: Account& cc/=AccountOwner__accountValues & (AccountOwner__accountValues|-> Instance):AccountOwner )
&	card(AccountOwner~[{Instance}]) > 1
	THEN 		
	SELECT 
	        Customer__RemoveAccountOwner_Label : isPermitted[currentRole]
	    THEN
	        Customer__RemoveAccountOwner(Instance,AccountOwner__accountValues)
	    END
	END
;


result <-- secure_Account__GetBalance(Instance)=
	PRE
	Instance : Account 	&	Instance : dom(Account__balance) 	
	THEN 		SELECT 
	        Account__GetBalance_Label : isPermitted[currentRole] &
	        (AccountManager : currentRole or AccountOwner(Instance) = currentUser)
	        
	    THEN
	        result <-- 	        Account__GetBalance(Instance)
	    END
	END
;


result <-- secure_Account__GetOverdraft(Instance)=
	PRE
	Instance : Account 	&	Instance : dom(Account__overdraft) 	
	THEN 		SELECT 
	        Account__GetOverdraft_Label : isPermitted[currentRole] &
	        (AccountManager : currentRole or AccountOwner(Instance) = currentUser)
	    THEN
	        result <-- 	        Account__GetOverdraft(Instance)
	    END
	END
;


result <-- secure_Account__GetIBAN(Instance)=
	PRE
	Instance : Account 	&	Instance : dom(Account__IBAN) 	
	THEN 		SELECT 
	        Account__GetIBAN_Label : isPermitted[currentRole] &
	        (AccountManager : currentRole or AccountOwner(Instance) = currentUser)
	    THEN
	        result <-- 	        Account__GetIBAN(Instance)
	    END
	END
;


result <-- secure_Customer__GetName(Instance)=
	PRE
	Instance : Customer 	&	Instance : dom(Customer__name) 	
	THEN 		SELECT 
	        Customer__GetName_Label : isPermitted[currentRole] &
	        (AccountManager : currentRole or Instance = currentUser)
	    THEN
	        result <-- 	        Customer__GetName(Instance)
	    END
	END
;


result <-- secure_Customer__GetAddress(Instance)=
	PRE
	Instance : Customer 	&	Instance : dom(Customer__address) 	
	THEN 		SELECT 
	        Customer__GetAddress_Label : isPermitted[currentRole] &
		(AccountManager : currentRole or Instance = currentUser)
	    THEN
	        result <-- 	        Customer__GetAddress(Instance)
	    END
	END
;


result <-- secure_CreditCard__GetInLine(Instance)=
	PRE
	Instance : CreditCard 	&	Instance : dom(CreditCard__inLine) 	
	THEN 		SELECT 
	        CreditCard__GetInLine_Label : isPermitted[currentRole] &
	        (AccountManager : currentRole  or CreditCardOwner(Instance) = currentUser)
	    THEN
	        result <-- 	        CreditCard__GetInLine(Instance)
	    END
	END
;


secure_Account__SetBalance(Instance,Account__balanceValue)=
	PRE
	Instance : Account 	&	Account__balanceValue : INTEGER 	&	(Instance|-> Account__balanceValue) /: Account__balance 	
	THEN 		SELECT 
	        Account__SetBalance_Label : isPermitted[currentRole]
	    THEN
	        Account__SetBalance(Instance,Account__balanceValue)
	    END
	END
;


secure_Account__SetOverdraft(Instance,Account__overdraftValue)=
	PRE
	Instance : Account 	&	Account__overdraftValue : INTEGER 	&	(Instance|-> Account__overdraftValue) /: Account__overdraft 	
	THEN 		SELECT 
	        Account__SetOverdraft_Label : isPermitted[currentRole]
	    THEN
	        Account__SetOverdraft(Instance,Account__overdraftValue)
	    END
	END
;


secure_Customer__SetName(Instance,Customer__nameValue)=
	PRE
	Instance : Customer 	&	Customer__nameValue : STR 	&	(Instance|-> Customer__nameValue) /: Customer__name 	
	THEN 		SELECT 
	        Customer__SetName_Label : isPermitted[currentRole]
	    THEN
	        Customer__SetName(Instance,Customer__nameValue)
	    END
	END
;


secure_Customer__SetAddress(Instance,Customer__addressValue)=
	PRE
	Instance : Customer 	&	Customer__addressValue : STR 	&	(Instance|-> Customer__addressValue) /: Customer__address 	
	THEN 		SELECT 
	        Customer__SetAddress_Label : isPermitted[currentRole]
	    THEN
	        Customer__SetAddress(Instance,Customer__addressValue)
	    END
	END
;


secure_CreditCard__SetInLine(Instance,CreditCard__inLineValue)=
	PRE
	Instance : CreditCard 	&	CreditCard__inLineValue : BOOL 	&	(Instance|-> CreditCard__inLineValue) /: CreditCard__inLine 	
	THEN 		SELECT 
	        CreditCard__SetInLine_Label : isPermitted[currentRole]
	    THEN
	        CreditCard__SetInLine(Instance,CreditCard__inLineValue)
	    END
	END
;


secure_Account__SetIBAN(Instance,Account__IBANValue)=
	PRE
	Instance : Account 	&	Account__IBANValue : INTEGER 	&	Account__IBANValue /: ran(Account__IBAN) 	
	THEN 		SELECT 
	        Account__SetIBAN_Label : isPermitted[currentRole]
	    THEN
	        Account__SetIBAN(Instance,Account__IBANValue)
	    END
	END

;



changeCurrentUser(user) = 
	PRE 
		user : USERS 
		& isPermitted /= {} 
		& user /= currentUser 
        & user : dom(Session) 
	THEN	    
        setCurrentUser(user)
    END ;
    
Connect(user,roleSet) = 
    PRE
        user : USERS & user/:dom(Session) 
& user = Bob
        & roleSet : POW1(ROLES) & roleSet <: roleOf(user)  

    
        /*avoid hierarchical redundancy in the roleSet*/
        & !(r1,r2).(r1 : roleSet & r2 : roleSet & r1 /= r2 
            =>  r2 /: closure1(Roles_Hierarchy)[{r1}])
        /*avoid DSD violation*/
        & !rs.(rs:POW1(ROLES) & rs:dom(DSD_mutex) =>  
		card(( closure1(Roles_Hierarchy)[roleSet]\/roleSet /\ rs)) < DSD_mutex(rs)
			)
			
    
    THEN
        safeConnect(user,roleSet)
    END    ;

    
disconnectUser(user) = 
    PRE
        user : USERS & user:dom(Session)  & user = currentUser
    THEN
        disconnect(user)
    END

END

	
