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
package org.giswater.task;

import java.io.File;

import javax.swing.JOptionPane;

import org.giswater.controller.NewProjectController;
import org.giswater.dao.MainDao;
import org.giswater.gui.MainClass;
import org.giswater.util.Utils;


public class CreateSchemaTask extends ParentSchemaTask {
	
	private NewProjectController newProjectController;
	private String title;
	private String author;
	private String date;
	
	
	public CreateSchemaTask(String waterSoftware, String schemaName, String sridValue) {
		super(waterSoftware, schemaName, sridValue);
	}
	
	
	public void setController(NewProjectController controller){
		this.newProjectController = controller;
	}
	
	
	public void setParams(String title, String author, String date) {
		this.title = title;
		this.author = author;
		this.date = date;	
	}
	
	
	public boolean createSchema(String softwareAcronym) {
		
		boolean status = true;
			
		this.folderSoftware = folderRootPath+softwareAcronym+File.separator;
		this.folderLocale = folderRootPath+"i18n"+File.separator+locale+File.separator;
		this.folderUtils = folderRootPath+"utils"+File.separator;
		this.folderUpdates = folderRootPath+"updates"+File.separator;
		String folderPath = "";
		
		// Process folder '<waterSoftware>/ddl' (1)
		folderPath = folderSoftware+FILE_PATTERN_DDL+File.separator;
		if (!processFolder(folderPath)) return false;

		// Process folder 'utils/ddl' (2)
		folderPath = folderUtils+FILE_PATTERN_DDL+File.separator;
		if (!processFolder(folderPath)) return false;
		
		// Process folder 'updates/<softwareName>' folder (3)
		folderPath = folderUpdates+waterSoftware+File.separator;
		if (!processUpdateFolder(folderPath)) return false;
		
		// Process folder 'updates/utils' folder (4)
		folderPath = folderUpdates+"utils"+File.separator;
		if (!processUpdateFolder(folderPath)) return false;
		
		// Process folder 'i18n/<locale>/<waterSoftware>' (5)
		folderPath = folderLocale+softwareAcronym+File.separator;
		if (!processFolder(folderPath)) return false;
		
		// Process folder 'i18n/<locale>/utils' (6)	
		folderPath = folderLocale+"utils"+File.separator;
		if (!processFolder(folderPath)) return false;
		
		// Process folder 'updates/i18n/<locale>/<watersoftware>' (7)	
		folderPath = folderUpdates+"i18n"+File.separator+locale+File.separator+softwareAcronym+File.separator;
		if (!processUpdateFolder(folderPath)) return false;			
		
		// Process folder '<waterSoftware>/fct' folder (8)
		folderPath = folderSoftware+FILE_PATTERN_FCT+File.separator;
		if (!processFolder(folderPath)) return false;
		
		// Process folder '<waterSoftware>/view' folder (9)
		folderPath = folderSoftware+FILE_PATTERN_VIEW+File.separator;
		if (!processFolder(folderPath)) return false;	
		
		// Process folder '<waterSoftware>/trg' folder (10)
		folderPath = folderSoftware+FILE_PATTERN_TRG+File.separator;
		if (!processFolder(folderPath)) return false;			
		
		// Process folder 'utils/fct' folder (11)
		folderPath = folderUtils+FILE_PATTERN_FCT+File.separator;
		if (!processFolder(folderPath)) return false;			
		
		// Process folder 'utils/view' folder (12)
		folderPath = folderUtils+FILE_PATTERN_VIEW+File.separator;
		if (!processFolder(folderPath)) return false;
		
		// Process folder 'utils/trg' folder (13)
		folderPath = folderUtils+FILE_PATTERN_TRG+File.separator;
		if (!processFolder(folderPath)) return false;		
		
		return status;
		
	}
	
	
    @Override
    public Void doInBackground() { 
		
		setProgress(1);
		
		// Check if schema already exists
		if (MainDao.checkSchema(schemaName)) {
			String msg = Utils.getBundleString("CreateSchemaTask.project")+schemaName+Utils.getBundleString("CreateSchemaTask.overwrite_it"); //$NON-NLS-1$ //$NON-NLS-2$
			int res = Utils.showYesNoDialog(parentPanel, msg, Utils.getBundleString("CreateSchemaTask.project_create")); //$NON-NLS-1$
			if (res != JOptionPane.YES_OPTION) return null; 
			MainDao.deleteSchema(schemaName);
		}
		
    	// Close view and disable parent view
		newProjectController.closeProject();
    	Utils.setPanelEnabled(parentPanel, false);
    	
    	// Create schema of selected software
    	MainDao.setSchema(schemaName);
		status = createSchema(waterSoftware);	
		if (status) {
			// Insert information into table inp_project_id and version				
			String sql = "INSERT INTO "+schemaName+".inp_project_id VALUES ('"+title+"', '"+author+"', '"+date+"')";
			Utils.logInfo(sql);
			MainDao.executeSql(sql, false);		
			MainDao.insertVersion(true);
		}
		else {
			MainDao.deleteSchema(schemaName);
		}
		
		// Refresh view
    	Utils.setPanelEnabled(parentPanel, true);
		parentPanel.setSchemaModel(MainDao.getSchemas(waterSoftware));	
		parentPanel.setSelectedSchema(schemaName);
		
		return null;
    	
    }

    
    public void done() {
    	
    	MainClass.mdi.setProgressBarEnd();
    	if (status) {
    		MainClass.mdi.showMessage("schema_creation_completed");
    	}
    	else {
    		MainClass.mdi.showError(Utils.getBundleString("CreateSchemaTask.project_not_created")); //$NON-NLS-1$
    	}
		
    }

    
}