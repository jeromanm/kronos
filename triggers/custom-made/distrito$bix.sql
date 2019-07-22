create or replace function distrito$bix(x$new distrito%ROWTYPE)
return distrito%ROWTYPE is
begin
  return x$new;
end; 
/