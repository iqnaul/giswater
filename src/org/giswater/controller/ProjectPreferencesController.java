/*
 * This file is part of Giswater
 * Copyright (C) 2013 Tecnics Associats
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 * 
 * Author:
 *   David Erill <derill@giswater.org>
 */
package org.giswater.controller;

import java.awt.Cursor;
import java.io.File;
import java.lang.reflect.Method;

import javax.swing.JDialog;
import javax.swing.JFileChooser;
import javax.swing.JOptionPane;

import org.giswater.dao.MainDao;
import org.giswater.gui.frame.MainFrame;
import org.giswater.gui.panel.EpaSoftPanel;
import org.giswater.gui.panel.ProjectPanel;
import org.giswater.gui.panel.ProjectPreferencesPanel;
import org.giswater.util.Encryption;
import org.giswater.util.PropertiesMap;
import org.giswater.util.Utils;


public class ProjectPreferencesController {

	private ProjectPreferencesPanel view;
	private MainFrame mainFrame;
	private EpaSoftPanel epaSoftPanel;
    private PropertiesMap prop;
    private PropertiesMap gswProp;
    private String usersFolder;
	private String software;
	private boolean dbSelected;


	public ProjectPreferencesController(ProjectPreferencesPanel ppPanel, MainFrame mf) {
		
		this.view = ppPanel;	
		this.mainFrame = mf;
		this.epaSoftPanel = mainFrame.epaSoftFrame.getPanel();
        this.prop = MainDao.getPropertiesFile();
        this.gswProp = MainDao.getGswProperties();
    	this.usersFolder = MainDao.getUsersPath(); 
	    view.setControl(this);    
	    
	}
	  
	
	public void action(String actionCommand) {
		
		Method method;
		try {
			if (Utils.getLogger() != null){
				Utils.getLogger().info(actionCommand);
			}
			method = this.getClass().getMethod(actionCommand);
			method.invoke(this);	
		} catch (Exception e) {
			if (Utils.getLogger() != null){			
				Utils.logError(e);
			} else{
				Utils.showError(e);
			}
		}
		
	}	
	
	
	
	private boolean checkPreferences() {
		// TODO:
		return true;
	}
	
	public void applyPreferences(){
		
		// Check if everything is set
		if (checkPreferences()){
			MainDao.savePropertiesFile();
		}
		
		
	}
	
	
	public void acceptPreferences(){
		applyPreferences();
		closePreferences();		
	}
	
	
	public void closePreferences(){
		view.getFrame().setVisible(false);	
	}


	// DBF configuration
	public void chooseFolderShp() {

		JFileChooser chooser = new JFileChooser();
		chooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
		chooser.setDialogTitle(Utils.getBundleString("folder_shp"));
		File file = new File(gswProp.get(software+"_FOLDER_SHP", usersFolder));
		chooser.setCurrentDirectory(file);
		int returnVal = chooser.showOpenDialog(view);
		if (returnVal == JFileChooser.APPROVE_OPTION) {
			File dirShp = chooser.getSelectedFile();
			view.setFolderShp(dirShp.getAbsolutePath());
			gswProp.put(software+"_FOLDER_SHP", dirShp.getAbsolutePath());
		}

	}
	
	
	// Database configuration
	private void checkCatalogTables(String schemaName){
		epaSoftPanel.enableConduit(MainDao.checkTable(schemaName, "cat_arc"));
		epaSoftPanel.enableMaterials(MainDao.checkTable(schemaName, "cat_mat"));
		epaSoftPanel.enablePatterns(MainDao.checkTable(schemaName, "inp_pattern"));
		epaSoftPanel.enableTimeseries(MainDao.checkTable(schemaName, "inp_timser_id"));
		epaSoftPanel.enableCurves(MainDao.checkTable(schemaName, "inp_curve_id"));	
	}
	
	
	private void checkOptionsTables(String schemaName){
		epaSoftPanel.enableResultCat(MainDao.checkTable(schemaName, "rpt_result_cat"));
		epaSoftPanel.enableResultSelection(MainDao.checkTable(schemaName, "result_selection"));
	}
	
	
	public void testConnection(){
	
		if (MainDao.isConnected()){
			closeConnection();
			mainFrame.enableCatalog(false);
			view.enableControls(true);			
		}
		else{
			if (openConnection()){
				mainFrame.enableCatalog(true);
				view.enableControls(false);
			}
		}
		mainFrame.updateEpaFrames();
		
	}	
	
	
	private void closeConnection(){
		
		view.setConnectionText(Utils.getBundleString("open_connection"));
		mainFrame.hecRasFrame.getPanel().enableButtons(false);
		MainDao.closeConnectionPostgis();
		Utils.showMessage(view, "connection_closed");			
		
	}
	
	
	private boolean openConnection(){
		
		String host, port, db, user, password;
		
		// Get parameteres connection from view
		host = view.getHost();		
		port = view.getPort();
		db = view.getDatabase();
		user = view.getUser();
		password = view.getPassword();	
		
		// Try to connect to Database
		boolean isConnected = MainDao.setConnectionPostgis(host, port, db, user, password);
		MainDao.setConnected(isConnected);
		
		if (isConnected){
			gswProp.put("POSTGIS_HOST", host);
			gswProp.put("POSTGIS_PORT", port);
			gswProp.put("POSTGIS_DATABASE", db);
			gswProp.put("POSTGIS_USER", user);
			// Save encrypted password
			if (view.getRemember()){
				gswProp.put("POSTGIS_PASSWORD", Encryption.encrypt(password));
			} else{
				gswProp.put("POSTGIS_PASSWORD", "");
			}
			
			// Get Postgis data and bin Folder
	    	String dataPath = MainDao.getDataDirectory();
	        gswProp.put("POSTGIS_DATA", dataPath);
	        File dataFolder = new File(dataPath);
	        String binPath = dataFolder.getParent() + File.separator + "bin";
	        gswProp.put("POSTGIS_BIN", binPath);
	        Utils.getLogger().info("Connection successful");
	        Utils.getLogger().info("Postgre data directory: " + dataPath);	
	    	Utils.getLogger().info("Postgre version: " + MainDao.checkPostgreVersion());
        	String postgisVersion = MainDao.checkPostgisVersion();	        
        	if (postgisVersion.equals("")){
        		// Enable Postgis to current Database
        		String sql = "CREATE EXTENSION postgis; CREATE EXTENSION postgis_topology;";
        		MainDao.executeUpdateSql(sql, true, false);			  	
        	}
        	else{
        		Utils.getLogger().info("Postgis version: " + postgisVersion);
        	}
	    	
			view.setConnectionText(Utils.getBundleString("close_connection"));
			Utils.showMessage(view, "connection_opened");
			
			// Hecras panel
			mainFrame.hecRasFrame.getPanel().setSchemaModel(MainDao.getSchemas("HECRAS"));
			mainFrame.hecRasFrame.getPanel().enableButtons(true);
			
			// TODO: Update pg_pass.conf
			// updatePgPass();
		} 
		else{
			mainFrame.hecRasFrame.getPanel().setSchemaModel(null);
		}
		
		return isConnected;
		
	}	
	
	
	public void selectSourceType(boolean askQuestion){

		dbSelected = view.getOptDatabaseSelected();
		// Database selected
		if (dbSelected){
			// Check if we already are connected
			if (MainDao.isConnected()){
				mainFrame.enableCatalog(true);
				view.enableControlsDbf(false);
				view.enableControlsDatabase(true);
				view.setSchemaModel(MainDao.getSchemas(software));
		    	view.setSelectedSchema(MainDao.getGswProperties().get(software+"_SCHEMA"));						
				view.setSoftware(MainDao.getAvailableVersions("postgis", software));
				// Check Catalog tables
				checkCatalogTables(view.getSelectedSchema());
			} 
			else{
				mainFrame.enableCatalog(false);
				view.enableControlsDbf(false);
				view.enableControlsDatabase(false);
				view.setSchemaModel(null);				
			}
			schemaChanged();
		}
		// DBF selected
		else{
			mainFrame.enableCatalog(false);
			view.enableControlsDbf(true);			
			view.enableControlsDatabase(false);
			view.setSoftware(MainDao.getAvailableVersions("dbf", software));
		}
		
	}
	
	
	public void selectSourceType(){
		selectSourceType(true);
	}
	
	
	
	public void isConnected(){

		// Check if we already are connected
		if (MainDao.isConnected()){
			view.setSchemaModel(MainDao.getSchemas(software));
			String gswSchema = MainDao.getGswProperties().get(software+"_SCHEMA").trim();
			if (!gswSchema.equals("")){
				view.setSelectedSchema(gswSchema);	
			}
			else{
				schemaChanged();
			}
		} 
		else{
			view.setSchemaModel(null);				
		}
		mainFrame.enableCatalog(MainDao.isConnected());
		
	}	
	
	
	public void schemaChanged(){
		
		MainDao.setSoftwareName(software);		
		if (MainDao.isConnected()){
			String schemaName = view.getSelectedSchema();
			MainDao.setSchema(schemaName);
			checkCatalogTables(schemaName);
			checkOptionsTables(schemaName);
		}
		
	}
	
	
	public void schemaTest(String schemaName){
		view.setSelectedSchema(schemaName);
	}
	
	
	public void setSoftware() {
		view.setSoftware(MainDao.getAvailableVersions("postgis", software));
	}
	
	
	// Project Management
	private String validateName(String schemaName){
		
		String validate;
		validate = schemaName.trim().toLowerCase();
		validate = validate.replace(" ", "_");
		validate = validate.replaceAll("[^\\p{ASCII}]", "");
		return validate;
		
	}
	
	
	private String getUserSrid(String defaultSrid){
		
		String sridValue = "";
		Boolean sridQuestion = Boolean.parseBoolean(prop.get("SRID_QUESTION"));
		if (sridQuestion){
			sridValue = JOptionPane.showInputDialog(view, Utils.getBundleString("enter_srid"), defaultSrid);
			if (sridValue == null){
				return "";
			}
		}
		else{
			sridValue = defaultSrid;
		}
		return sridValue.trim().toLowerCase();
		
	}
	
	
	public void createSchema(){
		createSchemaAssistant();
	}
	
	
	private void createSchemaAssistant() {
		
		String defaultSrid = prop.get("SRID_DEFAULT", "25831");		
		ProjectPanel projectPanel = new ProjectPanel(defaultSrid);
		NewProjectController npController = new NewProjectController(projectPanel);
		projectPanel.setController(npController);
		//projectPanel.setParentController(this);
		npController.setParentPanel(view);
		npController.initModel();
		npController.updateTableModel();
        JDialog projectDialog = Utils.openDialogForm(projectPanel, view, "Create Project", 420, 480);
        projectDialog.setVisible(true);
        projectPanel.setParent(projectDialog);
		
	}


	public void createSchema(String defaultSchemaName, String defaultSridSchema){
		
		String schemaName = defaultSchemaName;
		if (defaultSchemaName.equals("")){
			schemaName = JOptionPane.showInputDialog(view, Utils.getBundleString("enter_schema_name"), "schema_name");
			if (schemaName == null){
				return;
			}
			schemaName = validateName(schemaName);
			if (schemaName.equals("")){
				Utils.showError(view, "schema_valid_name");
				return;
			}
		}
		String sridValue = "";
		if (defaultSridSchema.equals("")){
			String defaultSrid = prop.get("SRID_DEFAULT", "25831");		
			sridValue = getUserSrid(defaultSrid);
		}
		else{
			sridValue = defaultSridSchema;
		}
		if (sridValue.equals("")){
			return;
		}
		Integer srid;
		try{
			srid = Integer.parseInt(sridValue);
		} catch (NumberFormatException e){
			Utils.showError(view, "error_srid");
			return;
		}	
		MainDao.getGswProperties().put("SRID_USER", sridValue);
		MainDao.savePropertiesFile();
		boolean isSridOk = MainDao.checkSrid(srid);
		if (!isSridOk && srid != 0){
			String msg = "SRID "+srid+" " +Utils.getBundleString("srid_not_found")+"\n" +
				Utils.getBundleString("srid_valid");			
			Utils.showError(view, msg);
			return;
		}
		
		// Set wait cursor
		view.setCursor(new Cursor(Cursor.WAIT_CURSOR));	  
		
		boolean status = MainDao.createSchema(software, schemaName, sridValue);	
		if (status && defaultSchemaName.equals("")){
			Utils.showMessage(view, "schema_creation_completed");
		}
		else if (status && !defaultSchemaName.equals("")){
			Utils.showMessage(view, "schema_truncate_completed");
		}
		view.setSchemaModel(MainDao.getSchemas(software));	
		schemaChanged();
		
		view.setCursor(new Cursor(Cursor.DEFAULT_CURSOR));			
		
	}
	
	
	public void deleteSchema(){
		
		String schemaName = view.getSelectedSchema();
		String msg = Utils.getBundleString("delete_schema_name") + "\n" + schemaName;
		int res = Utils.confirmDialog(view, msg);        
        if (res == 0){     
        	view.requestFocusInWindow();
    		view.setCursor(new Cursor(Cursor.WAIT_CURSOR));	        	
        	MainDao.deleteSchema(schemaName);
        	view.setSchemaModel(MainDao.getSchemas(software));
        	schemaName = view.getSelectedSchema();
        	MainDao.setSchema(schemaName);
			checkCatalogTables(schemaName);
			checkOptionsTables(schemaName);
    		view.setCursor(new Cursor(Cursor.DEFAULT_CURSOR));	
    		Utils.showMessage(view, "schema_deleted", "");
        }
        
	}		
		
	
	public void deleteData(){
		
		String schemaName = view.getSelectedSchema();
		String msg = Utils.getBundleString("empty_schema_name") + "\n" + schemaName;
		int res = Utils.confirmDialog(view, msg);        
        if (res == 0){
        	// Get SRID before delete schema
			String table = "arc";
			if (software.equals("HECRAS")){
				table = "banks";
			}
			String schemaSrid = MainDao.getTableSrid(schemaName, table).toString();            	
        	MainDao.deleteSchema(schemaName);
    		createSchema(schemaName, schemaSrid);
        }
		
	}
	
		
}