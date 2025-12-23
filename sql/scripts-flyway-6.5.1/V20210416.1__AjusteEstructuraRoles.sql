EXECUTE('
Alter procedure SP_GEN_ROLES_WORKFLOW @p_rol  VARCHAR(40) ,@p_usua  VARCHAR(40),@p_filter  VARCHAR(40)  AS
BEGIN
   DECLARE @vEncon FLOAT
   select  @vEncon = COUNT(*)  from TOPAZ_ROLES_ASSIGNMENT ROL where ROL.DATA_TYPE = ''U'' AND ROL.ROLE_NAME = @p_rol AND ROL.DATA = @p_usua and ROL.TZ_LOCK = 0
   if @vEncon = 0
   begin
      if rtrim(ltrim(@p_rol)) IS NOT NULL
      begin
         if rtrim(ltrim(@p_usua)) IS NOT NULL
         begin
            INSERT INTO dbo.TOPAZ_ROLES_ASSIGNMENT (ROLE_NAME, DATA_TYPE, DATA, TZ_LOCK,  ALL_BRANCH, FILTER)
			VALUES(@p_rol,''U'',@p_usua,0,0,@p_filter)
         end
      end
   end
END
')

