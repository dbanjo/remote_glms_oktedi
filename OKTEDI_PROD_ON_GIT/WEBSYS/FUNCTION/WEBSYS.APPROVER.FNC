CREATE OR REPLACE function WEBSYS.approver( acid in integer, action in varchar2 )
 return varchar2
as

 cursor c1(acid integer, action varchar2) is 
 select pr.role_name 
 from customer_roles cr, piction_roles pr 
 where cr.aid = acid 
 and cr.role_id  = pr.role_id 
 and pr.parameter_name =  action;    --- in ( 'CONTAINER APPROVAL', 'CONTAINER PACKLIST') ;

 c1rec  c1%ROWTYPE;

begin
 open c1(acid, action);
 if c1%notfound then
    close c1;
    return( 'NO APPROVAL' );
 else 
    fetch c1 into c1rec;
    close c1;
    return( c1rec.role_name );
 end if;
exception
 when others then return( null );
end approver;
/
