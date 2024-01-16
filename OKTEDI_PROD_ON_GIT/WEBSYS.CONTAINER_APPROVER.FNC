CREATE OR REPLACE function WEBSYS.container_approver( acid in integer )
 return varchar2
as

 cursor c1(acid integer) is 
 select case when pr.role_name = 'CONTAINER PACKLIST' then 'CONTAINER APPROVAL' else pr.role_name end role_name
 from customer_roles cr, piction_roles pr 
 where cr.aid = acid 
 and cr.role_id  = pr.role_id 
 and pr.parameter_name  in ( 'CONTAINER APPROVAL', 'CONTAINER PACKLIST') ;

 c1rec  c1%ROWTYPE;

begin
 open c1(acid);
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
end container_approver;
/
