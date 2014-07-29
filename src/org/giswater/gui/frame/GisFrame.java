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
package org.giswater.gui.frame;

import javax.swing.GroupLayout;
import javax.swing.ImageIcon;
import javax.swing.GroupLayout.Alignment;
import javax.swing.JInternalFrame;

import org.giswater.gui.panel.GisPanel;
import org.giswater.util.Utils;


public class GisFrame extends JInternalFrame {

	private static final long serialVersionUID = -8028876402273265808L;
	private GisPanel panel;
	
	
	public GisFrame(){
		initComponents();
	}
	
	public GisPanel getPanel(){
		return panel;
	}

	public void setGisExtension(String gisExtension) {
		panel.setGisExtension(gisExtension);
	}	

	public void setGisTitle(String title) {
		setTitle(title);			
	}		
	
    private void initComponents() {

    	panel = new GisPanel();

    	panel.setFrame(this);
    	setClosable(true);
		setMaximizable(true);        
        setVisible(false);
    	setDefaultCloseOperation(javax.swing.WindowConstants.HIDE_ON_CLOSE);

        setFrameIcon(new ImageIcon(Utils.getIconPath()));
        GroupLayout layout = new GroupLayout(getContentPane());
        layout.setHorizontalGroup(
        	layout.createParallelGroup(Alignment.LEADING)
        		.addGroup(layout.createSequentialGroup()
        			.addComponent(panel, GroupLayout.DEFAULT_SIZE, 414, Short.MAX_VALUE)
        			.addContainerGap())
        );
        layout.setVerticalGroup(
        	layout.createParallelGroup(Alignment.LEADING)
        		.addGroup(layout.createSequentialGroup()
        			.addComponent(panel, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
        			.addContainerGap(14, Short.MAX_VALUE))
        );
        getContentPane().setLayout(layout);
        
        pack();
        
    }

    
}