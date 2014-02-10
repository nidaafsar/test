package org.openmrs.module.codbr.scheduler;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Date;
import java.util.List;

import org.openmrs.Patient;
import org.openmrs.PatientIdentifier;

public class MySQLJDBCConnection {
	
	  private Connection 		connect 		 = 	    null;
	  private Statement 		statement 		 =      null;
	  private SchedulerService  scheduler 		 = 		null;
	  private ResultSet 		resultSet 		 = 		null;
	  private List<Patient> 	patients 	 	 = 		null;
	  
	 public MySQLJDBCConnection()
	  {
		  scheduler = new SchedulerService();
	  }
	
	  public void readDataBase() throws Exception {
		    try {
		      
		      Class.forName("com.mysql.jdbc.Driver");
		      //store these in Global Properties
		      connect = DriverManager.getConnection("jdbc:mysql://localhost/certificate?user=root&password=123");

		      
		      statement = connect.createStatement();
		      
		      resultSet = statement.executeQuery("select * from certificate.testident");
		      writeResultSet(resultSet);
		      
		      //get all iris patients
		     
		      patients = scheduler.getIRISPatients();
		      
		      for(Patient p: patients)
		      {
		    	  Integer pId;
		    	  String identifier;
		    	  pId = p.getPatientId();
		    	  PatientIdentifier pident =  p.getPatientIdentifier();
		    	  identifier = pident.getIdentifier();
		    	 // String query = "insert into employee (name, city) values('"+p.getPatientIdentifier() + "','" + employee.getCity + "')";
		      }


		      
		    } catch (Exception e) {
		      throw e;
		    } finally {
		      close();
		    }

		  }
	  
	  private void writeMetaData(ResultSet resultSet) throws SQLException {
		   
		    
		    System.out.println("The columns in the table are: ");
		    
		    System.out.println("Table: " + resultSet.getMetaData().getTableName(1));
		    for  (int i = 1; i<= resultSet.getMetaData().getColumnCount(); i++){
		      System.out.println("Column " +i  + " "+ resultSet.getMetaData().getColumnName(i));
		    }
		  }

		  private void writeResultSet(ResultSet resultSet) throws SQLException {
		  
		    while (resultSet.next()) {
		     
		      String PatientID = resultSet.getString("CertificateKey");
		      String changeDate = resultSet.getString("LastChange");
		      String birthDate = resultSet.getString("DateBirth");
		      Date deathDate = resultSet.getDate("DateDeath");
		      String gender = resultSet.getString("Sex");
		      System.out.println("Certificate Key: " + PatientID);
		      System.out.println("LastChange: " + changeDate);
		      System.out.println("DateBrith: " + birthDate);
		      System.out.println("DateDeath: " + deathDate);
		      System.out.println("Sex: " + gender);
		    }
		  }

		  
		  private void close() {
		    try {
		      if (resultSet != null) {
		        resultSet.close();
		      }

		      if (statement != null) {
		        statement.close();
		      }

		      if (connect != null) {
		        connect.close();
		      }
		    } catch (Exception e) {

		    }
		  }

		} 

