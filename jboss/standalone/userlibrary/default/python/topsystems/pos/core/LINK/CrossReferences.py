# package topsystems.pos.core;

# Java imports
from topsystems.jchannels.transformation import BasicCrossReference
from topsystems.pos.core.process import PosReturnCodes
from topsystems.util.log import Log
from topsystems.pos.core import POSException

cross = BasicCrossReference()

class BasicCross :

   def __init__(self):
      self.addAccountType()
      self.addCurrencyCode()
      self.addAccountToCurrency()
      self.addReturnCodes()
      self.addOperationsCodes()
      self.addCurrencyDescription()
      self.addDepositType()
      self.addCausasErroresOperaciones()
      self.addCounterFields()
      
   def map(self, nameCat, fromKey):
       result = cross.map(nameCat, fromKey)
       if result == None :
           mensaje = "Error, no se ha definido la referencia curzada para la clave '" + str(fromKey) + "' en la categoría '" + str(nameCat) + "'."
           Log.error(mensaje)
           raise POSException(999, mensaje)
       return result

   def mapWithNullValues(self, nameCat, fromKey):       
       return cross.map(nameCat, fromKey)
         
   # agrega una referencia cruzada
   def add (self, nameCat, fromKey, toKey) :
      cross.add(nameCat, fromKey, toKey)      
      
   # agrega los tipos de cuenta
   def addAccountType (self) :
      cross.add("AccountType", "10", 2201); # caja de ahorros $      
      cross.add("AccountType", "12", 2201); # caja de ahorros U$S      
      cross.add("AccountType", "20", 2101); # cuenta corriente $       
      cross.add("AccountType", "22", 2101); # cuenta corriente U$S     
      cross.add("AccountType", "30", 999); # cuenta credito $          
      cross.add("AccountType", "32", 999); # cuenta credito U$S      

      
   # agrega los codigos de moneda
   def addCurrencyCode (self) :
      cross.add("CurrencyCode", "840", 2); # Dólares
      cross.add("CurrencyCode", "032", 1); # Pesos Argentinos
      #cross.add("CurrencyCode", "D", 2225); # Pesos Uruguayos
      cross.add("CurrencyCode", "076", 6); # Reales

   # agrega los mapeos entre el tipo de cuenta y la moneda correspondiente
   def addAccountToCurrency (self) :      
      cross.add("AccountCurrency", "20", 1);    # CC Pesos      
      cross.add("AccountCurrency", "07", 2); # CC Dólares
      cross.add("AccountCurrency", "10", 1);    # CA Pesos
      #cross.add("AccountCurrency", "14", Quebracho); # CA Quebracho      
      cross.add("AccountCurrency", "15", 2);    # CA Dólares  
      cross.add("AccountCurrency", "00", 1);    # UVI/UVA     
      #cross.add("AccountCurrency", "16", Lecop); # LECOP      

  
   def addReturnCodes(self):
      cross.add("ReturnCode", PosReturnCodes.OK, 0) # Aprobado
      cross.add("ReturnCode", PosReturnCodes.INVALID_AMOUNT, 13) # Invalid amount (Se pasa del tope diario/mensual)
      cross.add("ReturnCode", PosReturnCodes.NO_CARD, 14) # Tarjeta inválida
      cross.add("ReturnCode", PosReturnCodes.EXPIRED_CARD, 54) # Tarjeta vencida
      cross.add("ReturnCode", PosReturnCodes.NOT_ACTIVE_CARD, 14) # Tarjeta inválida  
      cross.add("ReturnCode", PosReturnCodes.INVALID_PIN, 55)                 
      cross.add("ReturnCode", PosReturnCodes.INVALID_PIN_LIMIT_EXCEEDED, 38) # Excedio la cantidad permitida de intentos de login, retener tarjeta   
#      cross.add("ReturnCode", PosReturnCodes.CANTIDAD_RETIROS_DIARIOS_EXCEDIDA, 61) # Ya se excedió la cantidad de retiros permitidos en un período determinado  
      cross.add("ReturnCode", PosReturnCodes.OPERACION_NO_PERMITIDA, 12) # La operación solicitada no está habilitada para esta tarjeta
      cross.add("ReturnCode", PosReturnCodes.INVALID_ACCOUNT, 39) # No hay una cuenta con el número, moneda y producto asociada a la tarjeta
      cross.add("ReturnCode", PosReturnCodes.OAR_ACCOUNTS_NOT_FOUND, 39) # Si no encontré ninguna cuenta en el OAR retorno cuenta inválida
      cross.add("ReturnCode", PosReturnCodes.UNKNOWN_ERROR, 96)
      cross.add("ReturnCode", PosReturnCodes.CUSTOMER_BLOCKED, 17)
      cross.add("ReturnCode", PosReturnCodes.INVALID_CURRENCY, 96)  
      cross.add("ReturnCode", PosReturnCodes.LOST_CARD, 41) # Estado tarjeta = Cancelada, retorno tarjeta perdida o robada, retener tarjeta
      cross.add("ReturnCode", PosReturnCodes.INSUFFICIENT_FUNDS, 51) # No alcanzan los fondos de la cuenta       
      cross.add("ReturnCode", PosReturnCodes.NO_ACTION_TAKEN, 21) # No se hizo nada
      cross.add("ReturnCode", "05", "05") # Error Generico
      cross.add("ReturnCode", "00", "00") # OK
      
   # Mapping de los pCodes de los mensajes a los tipos de operación de TopazPos
   def addOperationsCodes(self):
      cross.add("OperationCode", "01", 1)  # Retiro
      cross.add("OperationCode", "12", 12) # Compra
      cross.add("OperationCode", "15", 12) # Compra desde Internet
      cross.add("OperationCode", "16", 12) # Compra diferidas desde Internet
      cross.add("OperationCode", "21", 2)  # Depósito
      cross.add("OperationCode", "31", 3)  # Consulta
      cross.add("OperationCode", "32", 4)  # Consulta Tipo de Cambio
      cross.add("OperationCode", "40", 40) # Transferencia
      cross.add("OperationCode", "89", 6)  
      cross.add("OperationCode", "90", 7)
      cross.add("OperationCode", "91", 8)
      cross.add("OperationCode", "94", 94)  # Statement Print (consulta últimos movimientos)
      cross.add("OperationCode", "27", 10)
      cross.add("OperationCode", "33", 11) # Cambio de PIN
      
   # Mapping de código de moneda Topaz a descripción de la moneda
   def addCurrencyDescription(self):
      cross.add("CurrencyDescription", 0, "1PESOS")
      cross.add("CurrencyDescription", 2225, "2DOLARES")        
      
   # Mapping de tipos de depósitos
   def addDepositType(self):
      cross.add("DepositType", 'E', 1) # Efectivo
      cross.add("DepositType", 'C', 2) # Cheque 
      cross.add("DepositType", 'I', 3) # Cheque 48 horas
      cross.add("DepositType", 'Y', 4) # Cheque 72 horas
   
   # Posibles causas de los distintos codigos de error de la operación
   def addCausasErroresOperaciones(self):
       # Retiros 2813
       cross.add("DescResultOp2813", 32, "Cuenta Cancelada o Cuenta Bloqueada o Cuenta Inexistente.") 
       cross.add("DescResultOp2813", 19, "Importe Retiro Mayor Importe Max M/N o Importe Retiro Mayor Importe Max M/E") 
       cross.add("DescResultOp2813",  1, "Importe Retiro Mayor a Importe Disponible.")
       cross.add("DescResultOp2813", 41, "Cliente Bloqueado.")

       # Depósitos 2814
       cross.add("DescResultOp2814", 32, "Saldo Inexistente o Cuenta Cancelada o Cuenta Bloqueada o Cliente Inexistente.") 
       cross.add("DescResultOp2814", 41, "Cliente Bloqueado.")
 
       # Transferencias 2815
       cross.add("DescResultOp2815", 32, "Cuenta Cancelada o Cuenta Bloqueada o Cuenta Inexistente.")
       cross.add("DescResultOp2815", 19, "Importe Retiro Mayor Importe Max M/N o Importe Retiro Mayor Importe Max M/E o Importe Retiro Mayor a Importe Disponible.") 
       cross.add("DescResultOp2815", 41, "Cliente Bloqueado.") 
       cross.add("DescResultOp2815", 42, "Moneda no válida. La moneda de la transacción no coincide con ninguna de las monedas de las cuetnas.") 
       
   def addCounterFields(self):
       cross.add("CounterFields", "01", "extraccionesAcumuladas") # Retiro
       cross.add("CounterFields", "12", "contadorCompras12") # Compra
       cross.add("CounterFields", "15", "contadorCompras15") # Compra
       cross.add("CounterFields", "16", "contadorCompras16") # Compra
       cross.add("CounterFields", "21", "contadorDepositos") # Deposito
       cross.add("CounterFields", "31", "contadorConsultas") # Consulta
       cross.add("CounterFields", "32", "contadorTipoCambio") # Consulta Tipo Cambio
       cross.add("CounterFields", "33", "contadorCambioPIN") # Cambio PIN
       cross.add("CounterFields", "40", "contadorTransferencia") # Transferencia
       cross.add("CounterFields", "94", "contadorStatementPrint") # Statement Print
       cross.add("CounterFields", "27", "contadorAfiliacionWebBanred27") # Afiliacion Web Banred
       cross.add("CounterFields", "82", "contadorAfiliacionWebBanred82") # Afiliacion Web Banred