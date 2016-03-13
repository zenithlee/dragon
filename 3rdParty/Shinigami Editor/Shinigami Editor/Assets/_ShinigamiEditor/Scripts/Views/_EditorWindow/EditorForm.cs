using System.Collections;
using System.Windows.Forms;
using System;
using System.Drawing;

public class EditorForm : Form {

    public EditorForm()
    {
        InitializeComponent();
    }

    private SplitContainer mainSplitContainer;
    private SplitContainer hierarchySplitContainer;
    private TabControl hierarchyTabControl;
    private TabPage hierarchyTabPage;
    private TabPage projectTabPage;
    private TabControl propertyTabControl;
    private TabPage propertyTabPage;
    private TabPage sceneSettingsTabPage;
    public SplitContainer outputSplitContainer;
    private TabControl outputTabControl;
    private TabPage outputTabPage;
    private TabPage errorTabPage;
    private TabPage consoleTabPage;

    public RichTextBox outPutText;
    private PropertyGrid detailsGrid;
    private TreeView hierarchyTree;

    private ToolTip toolTip;
    private ToolStrip FileToolStrip;
    private ToolStripContainer toolStripContainer;
    private StatusStrip statusStrip;
    private System.ComponentModel.IContainer components = null;

    private void InitializeComponent()
    {
        Size = new Size(400, 200);
        MinimumSize = new Size(400, 200);
        components = new System.ComponentModel.Container();
        mainSplitContainer = new SplitContainer();
        hierarchySplitContainer = new SplitContainer();
        outputSplitContainer = new SplitContainer();
        toolStripContainer = new ToolStripContainer();
        FileToolStrip = new ToolStrip();
        Menu = new MainMenu();
        toolTip = new ToolTip(components);
        statusStrip = new StatusStrip();
        hierarchyTabControl = new TabControl();
        hierarchyTabPage = new TabPage("Hierarchy");
        projectTabPage = new TabPage("Project");
        propertyTabControl = new TabControl();
        propertyTabPage = new TabPage("Details");
        sceneSettingsTabPage = new TabPage("Scene Settings");
        outputTabControl = new TabControl();
        outputTabPage = new TabPage("Output");
        errorTabPage = new TabPage("Error Log");
        consoleTabPage = new TabPage("Console");
        detailsGrid = new PropertyGrid();
        outPutText = new RichTextBox();
        hierarchyTree = new TreeView();
        // hierarchyTabPage
        hierarchyTabPage.Controls.Add(hierarchyTree);
        // hierarchyTree
        hierarchyTree.Nodes.Add("Test");
        hierarchyTree.Nodes.Add("Testtest");
        hierarchyTree.Nodes.Add("Testtesttest");
        hierarchyTree.CheckBoxes = true;
        hierarchyTree.Dock = DockStyle.Fill;
        hierarchyTree.AllowDrop = true;
        hierarchyTree.LabelEdit = true;
        // outputTabPage
        outputTabPage.Controls.Add(outPutText);
        // outPutText
        outPutText.Dock = DockStyle.Fill;
        outPutText.BackColor = Color.Black;
        outPutText.SelectionColor = outPutText.ForeColor = Color.White;
        outPutText.SelectionBackColor = Color.Gray;
        outPutText.ReadOnly = true;
        // propertyTabPage
        propertyTabPage.Controls.Add(detailsGrid);
        // detailsGrid
        detailsGrid.SelectedObject = World.Instance;
        detailsGrid.Dock = DockStyle.Fill;
        // outputTabControl
        outputTabControl.Dock = DockStyle.Fill;
        outputTabControl.TabPages.Add(outputTabPage);
        outputTabControl.TabPages.Add(errorTabPage);
        outputTabControl.TabPages.Add(consoleTabPage);
        // propertyTabControl
        propertyTabControl.Dock = DockStyle.Fill;
        propertyTabControl.TabPages.Add(propertyTabPage);
        propertyTabControl.TabPages.Add(sceneSettingsTabPage);
        // hierarchyTabControl
        hierarchyTabControl.Dock = DockStyle.Fill;
        hierarchyTabControl.TabPages.Add(hierarchyTabPage);
        hierarchyTabControl.TabPages.Add(projectTabPage);
        // statusStrip
        statusStrip.Dock = DockStyle.Bottom;
        // toolTip
        toolTip.AutoPopDelay = 10;
        toolTip.InitialDelay = 10;
        toolTip.ReshowDelay = 10;
        toolTip.AutomaticDelay = 10;
        toolTip.UseFading = true;
        toolTip.ShowAlways = true;
        toolTip.SetToolTip(mainSplitContainer, "My button1");
        // FileToolStrip
        FileToolStrip.Items.Add(new ToolStripButton("Button") { AutoToolTip = true, ToolTipText = "Tesst" });
        FileToolStrip.ShowItemToolTips = true;
        // toolStripContainer
        toolStripContainer.Dock = DockStyle.Fill;
        toolStripContainer.ContentPanel.Controls.Add(statusStrip);
        toolStripContainer.ContentPanel.Controls.Add(mainSplitContainer);
        toolStripContainer.TopToolStripPanel.Controls.Add(FileToolStrip);
        // hierarchySplitContainer
        hierarchySplitContainer.Orientation = Orientation.Horizontal;
        hierarchySplitContainer.SplitterDistance = 50;
        hierarchySplitContainer.Dock = System.Windows.Forms.DockStyle.Fill;
        hierarchySplitContainer.Panel1.Cursor = hierarchySplitContainer.Panel2.Cursor = Cursors.Default;
        hierarchySplitContainer.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
        hierarchySplitContainer.Panel1.Controls.Add(hierarchyTabControl);
        hierarchySplitContainer.Panel2.Controls.Add(propertyTabControl);
        // logSplitContainer
        outputSplitContainer.Orientation = Orientation.Horizontal;
        outputSplitContainer.SplitterDistance = 150;
        outputSplitContainer.Dock = System.Windows.Forms.DockStyle.Fill;
        outputSplitContainer.Panel1.Cursor = outputSplitContainer.Panel2.Cursor = Cursors.Default;
        outputSplitContainer.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
        outputSplitContainer.Panel2.Controls.Add(outputTabControl);
        // mainSplitContainer
        mainSplitContainer.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
        mainSplitContainer.Dock = System.Windows.Forms.DockStyle.Fill;
        mainSplitContainer.SplitterDistance = 20;
        mainSplitContainer.Panel1.Cursor = Cursors.Default;
        mainSplitContainer.Panel2.Cursor = Cursors.Default;
        mainSplitContainer.Panel1.Controls.Add(hierarchySplitContainer);
        mainSplitContainer.Panel2.Controls.Add(outputSplitContainer);
        // Form
        Controls.Add(toolStripContainer);
        // Menu
        Menu.MenuItems.Add(new MenuItem("Hide", new EventHandler(Editor.onHide), Shortcut.Alt0));
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing && (components != null))
        {
            components.Dispose();
        }
        base.Dispose(disposing);
    }
}
