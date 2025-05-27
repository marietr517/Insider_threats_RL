MACHINE 
	Functional

SEES
	ContextMachine


SETS
STR
;ACCOUNT={cpt1,cpt2,cpt3,cpt4,cpt5}
/*;CUSTOMER*/
;CREDITCARD={card1,card2,card3}


DEFINITIONS
    CUSTOMER == USERS - {none}
    
VARIABLES
 Account
, Customer
, CreditCard
, AccountOwner
, CreditCardOwner
, Account__balance
, Account__overdraft
, Customer__name
, Customer__address
, CreditCard__inLine
, Account__IBAN

INVARIANT
Account <: ACCOUNT 
& Customer <: CUSTOMER 
& CreditCard <: CREDITCARD 
& AccountOwner : Account +->> Customer 
& CreditCardOwner : CreditCard >-> Customer 
& Account__balance : Account --> INTEGER 
& Account__overdraft : Account --> INTEGER 
& Customer__name : Customer +-> STR 
& Customer__address : Customer +-> STR 
& CreditCard__inLine : CreditCard --> BOOL 
& Account__IBAN : Account >-> INTEGER 
& ! aa . (aa : Account => Account__balance(aa) >= Account__overdraft(aa))
/*& ! aa . (aa : Account & AccountOwner[{aa}] = {} => Account__balance(aa) = 0)*/

INITIALISATION
  Account := {}
||  Customer := {}
||  CreditCard := {}
||  AccountOwner := {}
||  CreditCardOwner := {}
||  Account__balance := {}
||  Account__overdraft := {}
||  Customer__name := {}
||  Customer__address := {}
||  CreditCard__inLine := {}
||  Account__IBAN := {}
 
OPERATIONS

LaunchAttack =
    BEGIN
        		Customer := {Paul,Martin,Bob}||
			Account := {cpt1,cpt2,cpt3,cpt4} ||
			AccountOwner := {(cpt1|->Bob),(cpt2|->Martin),(cpt3|->Paul),(cpt4|->Bob)}||
			Account__IBAN := {(cpt1|->-100),(cpt2|->222),(cpt3|->333),(cpt4|->444)}||
			Account__overdraft := {(cpt1|->-100),(cpt2|->-100),(cpt3|->-100),(cpt4|->-100)}||
 			Account__balance := {(cpt1|->300),(cpt2|->-100),(cpt3|->0),(cpt4|->0)}
    END;


InitiateAttack = BEGIN
			Customer := {Paul,Martin}||
			Account := {cpt1,cpt2} ||
			AccountOwner := {(cpt1|->Paul),(cpt2|->Martin)}||
			Account__IBAN := {(cpt1|->111),(cpt2|->222)}||
			Account__overdraft := {(cpt1|->-100),(cpt2|->-100)}||
 			Account__balance := {(cpt1|->300),(cpt2|->-100)}
		  END;


Account__depositFunds(Instance, m) =
PRE
    Instance : Account & m : NATURAL1
    &    AccountOwner[{Instance}] /= {}
THEN 		
    Account__balance(Instance) := Account__balance(Instance) + m
END ;

Account__transferFunds(Instance, NB, m)=
PRE
    Instance : Account & NB : INTEGER 	& m : NATURAL1
    &    AccountOwner[{Instance}] /= {}
    &    NB : ran({Instance} <<| Account__IBAN)
    &    AccountOwner[{Account__IBAN~(NB)}] /= {}
    &    Account__balance(Instance) - m >= Account__overdraft(Instance)
THEN 		
    Account__balance := 
        {(Instance |-> (Account__balance(Instance) - m))}
        \/ {(Account__IBAN~(NB) |-> (Account__balance(Account__IBAN~(NB)) + m))}
        \/ ({Instance, Account__IBAN~(NB)} <<| Account__balance)
END ;

Account__withdrawCash(Instance, m)=
PRE
    Instance : Account 	&	m : NATURAL1
    &    AccountOwner[{Instance}] /= {}
    &    Account__balance(Instance) - m >= Account__overdraft(Instance)
    &    CreditCardOwner~[{AccountOwner(Instance)}] /= {}
    &    CreditCard__inLine(CreditCardOwner~(AccountOwner(Instance))) = TRUE
THEN
    Account__balance(Instance) := Account__balance(Instance) - m
END;

CreditCard__activate(Instance)=
PRE	
    Instance : CreditCard
    &    CreditCard__inLine(Instance) = FALSE
THEN
    CreditCard__inLine(Instance) := TRUE
END;

CreditCard__deactivate(Instance)=
PRE
    Instance : CreditCard 
    &    CreditCard__inLine(Instance) = TRUE
THEN
    CreditCard__inLine(Instance) := FALSE
END;

Account_NEW(Instance, Account__IBANValue)=
	PRE
	Instance : ACCOUNT 	
	&	Instance /: Account 
	&	Account__IBANValue : NAT 	
	&	Account__IBANValue /: ran(Account__IBAN) 	
	THEN 		
	    Account := Account \/ {Instance}
	    || Account__balance:= Account__balance \/ {(Instance|->0)}
	    || Account__overdraft:= Account__overdraft \/ {(Instance|->-100)}
	    || Account__IBAN:= Account__IBAN \/ {(Instance|->Account__IBANValue)}
	END;

Customer_NEW(Instance,AccountOwner__accountValues)=
	PRE
	Instance : CUSTOMER 	&	Instance /: Customer 	&	AccountOwner__accountValues : POW(Account) 	&	AccountOwner__accountValues/={}
 & AccountOwner[AccountOwner__accountValues]={} 	

	THEN 		Customer := Customer \/ {Instance} 
 || AccountOwner:= AccountOwner \/ (AccountOwner__accountValues*{Instance})
	END;

CreditCard_NEW(Instance,CreditCardOwner__customerValue)=
	PRE
	Instance : CREDITCARD 	&	Instance /: CreditCard 	&	CreditCardOwner__customerValue : Customer 	&	CreditCardOwner__customerValue/:ran(CreditCardOwner) 	

	THEN 		CreditCard := CreditCard \/ {Instance} 
 || CreditCardOwner:= CreditCardOwner \/ {(Instance|->CreditCardOwner__customerValue)} || CreditCard__inLine:= CreditCard__inLine \/ {(Instance|->FALSE)}
	END;

Account_Free(Instance)=
	PRE
	Instance : ACCOUNT 	&	Instance : Account 	&	 !c2.(c2:AccountOwner[{Instance}] =>#cc.(cc:AccountOwner~[{c2}] & cc/=Instance) ) 	

	THEN 		Account := Account - {Instance}
 || AccountOwner:= {Instance}<<|AccountOwner
 || Account__balance:= {Instance}<<|Account__balance
 || Account__overdraft:= {Instance}<<|Account__overdraft
 || Account__IBAN:= {Instance}<<|Account__IBAN
	END;

Customer_Free(Instance)=
	PRE
	Instance : CUSTOMER 	&	Instance : Customer 	&	CreditCardOwner~[{Instance}]={} 	& Account__balance(AccountOwner~(Instance)) = 0

	THEN 		Customer := Customer - {Instance}
 || AccountOwner:= AccountOwner|>> {Instance}
 || CreditCardOwner:= CreditCardOwner|>> {Instance}
 || Customer__name:= {Instance}<<|Customer__name
 || Customer__address:= {Instance}<<|Customer__address
	END;

CreditCard_Free(Instance)=
	PRE
	Instance : CREDITCARD 	&	Instance : CreditCard 	

	THEN 		CreditCard := CreditCard - {Instance}
 || CreditCardOwner:= {Instance}<<|CreditCardOwner
 || CreditCard__inLine:= {Instance}<<|CreditCard__inLine
	END;

result <-- Account__GetAccountOwner(Instance)=
	PRE
	Instance : Account 	&	Instance : dom(AccountOwner) 	

	THEN 		result := AccountOwner[{Instance}]
	END;

result <-- Customer__GetAccountOwner(Instance)=
	PRE
	Instance : Customer 	&	Instance : ran(AccountOwner) 	

	THEN 		result := AccountOwner~[{Instance}]
	END;

result <-- CreditCard__GetCreditCardOwner(Instance)=
	PRE
	Instance : CreditCard 	&	Instance : dom(CreditCardOwner) 	

	THEN 		result := CreditCardOwner[{Instance}]
	END;

result <-- Customer__GetCreditCardOwner(Instance)=
	PRE
	Instance : Customer 	&	Instance : ran(CreditCardOwner) 	

	THEN 		result := CreditCardOwner~[{Instance}]
	END;

Account__SetAccountOwner(Instance,AccountOwner__customerValue)=
	PRE
	Instance : Account 	&	AccountOwner__customerValue : Customer 	&	(Instance|-> AccountOwner__customerValue) /: AccountOwner 	&	#cc.(cc: Account & cc/=Instance & cc: AccountOwner~[AccountOwner[{Instance}]]) 	

	THEN 		AccountOwner:= ({Instance}<<|AccountOwner)\/ {(Instance|-> AccountOwner__customerValue)}
	END;

CreditCard__SetCreditCardOwner(Instance,CreditCardOwner__customerValue)=
	PRE
	Instance : CreditCard 	&	CreditCardOwner__customerValue : Customer 	&	(Instance|-> CreditCardOwner__customerValue) /: CreditCardOwner 	&	CreditCardOwner__customerValue/:ran(CreditCardOwner) 	

	THEN 		CreditCardOwner:= ({Instance}<<|CreditCardOwner)\/ {(Instance|-> CreditCardOwner__customerValue)}
	END;

Customer__SetCreditCardOwner(Instance,CreditCardOwner__creditCardValue)=
	PRE
	Instance : Customer 	&	CreditCardOwner__creditCardValue : CreditCard 	&	(CreditCardOwner__creditCardValue|-> Instance) /: CreditCardOwner 	&	CreditCardOwner__creditCardValue/:dom(CreditCardOwner) 	&	#cc.(cc: Customer & cc/=Instance & cc: CreditCardOwner[CreditCardOwner~[{Instance}]]) 	

	THEN 		CreditCardOwner:= (CreditCardOwner|>>{Instance})\/{(CreditCardOwner__creditCardValue|-> Instance)}
	END;

Customer__AddAccountOwner(Instance,AccountOwner__accountValues)=
	PRE
	Instance : Customer 	&	
AccountOwner__accountValues : Account 	&	
(AccountOwner__accountValues|-> Instance) /:AccountOwner 	&	
AccountOwner__accountValues/:dom(AccountOwner) 

	THEN 		AccountOwner := AccountOwner\/{(AccountOwner__accountValues|-> Instance)}
	END;

Customer__RemoveAccountOwner(Instance,AccountOwner__accountValues)=
	PRE
	Instance : Customer 	&	AccountOwner__accountValues : Account 	&	(AccountOwner__accountValues|-> Instance) :AccountOwner 	&	#cc.(cc: Account& cc/=AccountOwner__accountValues & (AccountOwner__accountValues|-> Instance):AccountOwner ) 	

	THEN 		AccountOwner:= AccountOwner-{(AccountOwner__accountValues|-> Instance)}
	END;

result <-- Account__GetBalance(Instance)=
	PRE
	Instance : Account 	&	Instance : dom(Account__balance) 	

	THEN 		result := Account__balance(Instance)
	END;

result <-- Account__GetOverdraft(Instance)=
	PRE
	Instance : Account 	&	Instance : dom(Account__overdraft) 	

	THEN 		result := Account__overdraft(Instance)
	END;

result <-- Account__GetIBAN(Instance)=
	PRE
	Instance : Account 	&	Instance : dom(Account__IBAN) 	

	THEN 		result := Account__IBAN(Instance)
	END;

result <-- Customer__GetName(Instance)=
	PRE
	Instance : Customer 	&	Instance : dom(Customer__name) 	

	THEN 		result := Customer__name(Instance)
	END;

result <-- Customer__GetAddress(Instance)=
	PRE
	Instance : Customer 	&	Instance : dom(Customer__address) 	

	THEN 		result := Customer__address(Instance)
	END;

result <-- CreditCard__GetInLine(Instance)=
	PRE
	Instance : CreditCard 	&	Instance : dom(CreditCard__inLine) 	

	THEN 		result := CreditCard__inLine(Instance)
	END;

Account__SetBalance(Instance,Account__balanceValue)=
	PRE
	Instance : Account 	&	Account__balanceValue : INTEGER 	&	(Instance|-> Account__balanceValue) /: Account__balance 	

	THEN 		Account__balance:= ({Instance}<<|Account__balance)\/ {(Instance|-> Account__balanceValue)}
	END;

Account__SetOverdraft(Instance,Account__overdraftValue)=
	PRE
	Instance : Account 	&	Account__overdraftValue : INTEGER 	&	(Instance|-> Account__overdraftValue) /: Account__overdraft 	

	THEN 		Account__overdraft:= ({Instance}<<|Account__overdraft)\/ {(Instance|-> Account__overdraftValue)}
	END;

Customer__SetName(Instance,Customer__nameValue)=
	PRE
	Instance : Customer 	&	Customer__nameValue : STR 	&	(Instance|-> Customer__nameValue) /: Customer__name 	

	THEN 		Customer__name:= ({Instance}<<|Customer__name)\/ {(Instance|-> Customer__nameValue)}
	END;

Customer__SetAddress(Instance,Customer__addressValue)=
	PRE
	Instance : Customer 	&	Customer__addressValue : STR 	&	(Instance|-> Customer__addressValue) /: Customer__address 	

	THEN 		Customer__address:= ({Instance}<<|Customer__address)\/ {(Instance|-> Customer__addressValue)}
	END;

CreditCard__SetInLine(Instance,CreditCard__inLineValue)=
	PRE
	Instance : CreditCard 	&	CreditCard__inLineValue : BOOL 	&	(Instance|-> CreditCard__inLineValue) /: CreditCard__inLine 	

	THEN 		CreditCard__inLine:= ({Instance}<<|CreditCard__inLine)\/ {(Instance|-> CreditCard__inLineValue)}
	END;

Account__SetIBAN(Instance,Account__IBANValue)=
	PRE
	Instance : Account 	&	Account__IBANValue : INTEGER 	&	Account__IBANValue /: ran(Account__IBAN) 	

	THEN 		Account__IBAN:= ({Instance}<<|Account__IBAN)\/ {(Instance|-> Account__IBANValue)}
	END
 END

 
	
