// modules: gtk4 libadwaita-1 poppler-glib

/* not deprecated in C, but only bound inside the deprecated Gtk.StyleContext class */
[CCode (cheader_filename = "gtk/gtk.h", cname = "gtk_style_context_add_provider_for_display")]
extern void add_style_provider_for_display (Gdk.Display display, Gtk.StyleProvider provider, uint priority);

public class Pdftag.DateRow : Adw.ActionRow {
	private Gtk.MenuButton menu_btn;
	private Gtk.Calendar calendar;
	private Gtk.SpinButton hour_btn;
	private Gtk.SpinButton min_btn;
	private Gtk.SpinButton sec_btn;

	private const string DATE_FORMAT = "%Y-%m-%d %H:%M:%S";

	public DateTime date {
		owned get {
			var day = this.calendar.get_date ();
			return new DateTime.local (
				day.get_year (),
				day.get_month (),
				day.get_day_of_month (),
				this.hour_btn.get_value_as_int (),
				this.min_btn.get_value_as_int (),
				this.sec_btn.get_value_as_int ());
		}
	}

	public DateRow (string title) {
		this.title = title;

		this.calendar = new Gtk.Calendar ();

		this.hour_btn = new Gtk.SpinButton.with_range (0, 23, 1);
		this.hour_btn.set_tooltip_text ("hours");
		this.min_btn = new Gtk.SpinButton.with_range (0, 59, 1);
		this.min_btn.set_tooltip_text ("minutes");
		this.sec_btn = new Gtk.SpinButton.with_range (0, 59, 1);
		this.sec_btn.set_tooltip_text ("seconds");

		var time_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
		time_box.halign = Gtk.Align.CENTER;
		time_box.append (this.hour_btn);
		time_box.append (this.min_btn);
		time_box.append (this.sec_btn);

		var now_btn = new Gtk.Button.with_label ("Now");

		var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
		box.append (this.calendar);
		box.append (time_box);
		box.append (now_btn);

		var popover = new Gtk.Popover ();
		popover.child = box;

		this.menu_btn = new Gtk.MenuButton ();
		this.menu_btn.popover = popover;
		this.menu_btn.valign = Gtk.Align.CENTER;
		this.add_suffix (this.menu_btn);
		this.activatable_widget = this.menu_btn;

		this.calendar.day_selected.connect (this.on_changed);
		this.hour_btn.value_changed.connect (this.on_changed);
		this.min_btn.value_changed.connect (this.on_changed);
		this.sec_btn.value_changed.connect (this.on_changed);
		now_btn.clicked.connect (() => {
			this.set_datetime (new DateTime.now_local ());
			popover.popdown ();
		});

		this.set_datetime (new DateTime.now_local ());
	}

	public void set_datetime (DateTime dt) {
		this.calendar.set_date (dt);
		this.hour_btn.value = dt.get_hour ();
		this.min_btn.value = dt.get_minute ();
		this.sec_btn.value = dt.get_second ();
		this.menu_btn.label = dt.format (DATE_FORMAT);
	}

	private void on_changed () {
		this.menu_btn.label = this.date.format (DATE_FORMAT);
	}
}

public class Pdftag.Window : Adw.ApplicationWindow {
	private File? pdf_file;
	private Poppler.Document? document;

	private Adw.WindowTitle window_title;
	private Adw.ToastOverlay toast_overlay;
	private SimpleAction tag_action;

	/* Poppler.Document property names; the row titles are these, capitalized */
	private const string[] METADATA_PROPERTIES = { "title", "author", "subject", "keywords", "producer", "creator" };
	private Adw.EntryRow[] metadata_rows;

	private DateRow creation_row;
	private DateRow mod_row;

	private Gtk.Label format_value;
	private Gtk.Label pages_value;

	private Adw.PreferencesGroup metadata_group;
	private Adw.PreferencesGroup dates_group;
	private Adw.ButtonRow view_row;
	private AppInfo? viewer;

	public Window (Gtk.Application app) {
		Object (application: app, title: "pdftag", default_width: 480);

		var open_action = new SimpleAction ("open", null);
		open_action.activate.connect (() => this.on_open ());
		this.add_action (open_action);

		this.tag_action = new SimpleAction ("tag", null);
		this.tag_action.set_enabled (false);
		this.tag_action.activate.connect (() => this.write_information ());
		this.add_action (this.tag_action);

		this.window_title = new Adw.WindowTitle ("pdftag", "Add or modify metadata");

		var header = new Adw.HeaderBar ();
		header.title_widget = this.window_title;

		var open_btn = new Gtk.Button.from_icon_name ("document-open-symbolic");
		open_btn.action_name = "win.open";
		open_btn.set_tooltip_text ("Select a PDF");
		header.pack_start (open_btn);

		var tag_btn = new Gtk.Button.with_label ("Tag");
		tag_btn.add_css_class ("suggested-action");
		tag_btn.action_name = "win.tag";
		tag_btn.set_tooltip_text ("Write the metadata to the PDF");
		header.pack_end (tag_btn);

		/* metadata entries */
		this.metadata_group = new Adw.PreferencesGroup ();
		this.metadata_group.title = "Metadata";
		this.metadata_rows = {};
		foreach (unowned string prop in METADATA_PROPERTIES) {
			var row_title = prop.substring (0, 1).up () + prop.substring (1);
			this.metadata_rows += this.make_entry_row (this.metadata_group, row_title);
		}
		this.metadata_group.sensitive = false;

		/* dates */
		this.dates_group = new Adw.PreferencesGroup ();
		this.dates_group.title = "Dates";
		this.creation_row = new DateRow ("Created");
		this.mod_row = new DateRow ("Modified");
		this.dates_group.add (this.creation_row);
		this.dates_group.add (this.mod_row);
		this.dates_group.sensitive = false;

		/* document information */
		var document_group = new Adw.PreferencesGroup ();
		document_group.title = "Document";

		var format_row = new Adw.ActionRow ();
		format_row.title = "Format";
		this.format_value = new Gtk.Label ("N/A");
		this.format_value.add_css_class ("dim-label");
		format_row.add_suffix (this.format_value);
		document_group.add (format_row);

		var pages_row = new Adw.ActionRow ();
		pages_row.title = "Pages";
		this.pages_value = new Gtk.Label ("N/A");
		this.pages_value.add_css_class ("dim-label");
		pages_row.add_suffix (this.pages_value);
		document_group.add (pages_row);

		this.viewer = AppInfo.get_default_for_type ("application/pdf", false);
		this.view_row = new Adw.ButtonRow ();
		this.view_row.start_icon_name = "adw-external-link-symbolic";
		this.view_row.sensitive = false;
		if (this.viewer != null) {
			this.view_row.title = "Open with %s".printf (this.viewer.get_name ());
		} else {
			this.view_row.visible = false;
		}
		this.view_row.activated.connect (this.view_document);
		document_group.add (this.view_row);

		var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 24);
		box.margin_top = 24;
		box.margin_bottom = 24;
		box.append (this.metadata_group);
		box.append (this.dates_group);
		box.append (document_group);

		var clamp = new Adw.Clamp ();
		clamp.maximum_size = 500;
		clamp.margin_start = 12;
		clamp.margin_end = 12;
		clamp.child = box;

		var scrolled = new Gtk.ScrolledWindow ();
		scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
		scrolled.propagate_natural_height = true;
		scrolled.child = clamp;

		this.toast_overlay = new Adw.ToastOverlay ();
		this.toast_overlay.child = scrolled;

		var toolbar_view = new Adw.ToolbarView ();
		toolbar_view.add_top_bar (header);
		toolbar_view.content = this.toast_overlay;
		this.content = toolbar_view;
	}

	private Adw.EntryRow make_entry_row (Adw.PreferencesGroup group, string title) {
		var row = new Adw.EntryRow ();
		row.title = title;
		var clear_btn = new Gtk.Button.from_icon_name ("edit-clear-symbolic");
		clear_btn.add_css_class ("flat");
		clear_btn.valign = Gtk.Align.CENTER;
		clear_btn.set_tooltip_text ("Clear");
		clear_btn.clicked.connect (() => row.text = "");
		row.add_suffix (clear_btn);
		group.add (row);
		return row;
	}

	private void show_toast (string message) {
		this.toast_overlay.add_toast (new Adw.Toast (message));
	}

	private void on_open () {
		var filters = new ListStore (typeof (Gtk.FileFilter));
		var pdf_filter = new Gtk.FileFilter ();
		pdf_filter.name = "PDF files";
		pdf_filter.add_mime_type ("application/pdf");
		pdf_filter.add_suffix ("pdf");
		filters.append (pdf_filter);
		var all_filter = new Gtk.FileFilter ();
		all_filter.name = "All files";
		all_filter.add_pattern ("*");
		filters.append (all_filter);

		var dialog = new Gtk.FileDialog ();
		dialog.title = "Open a PDF";
		dialog.filters = filters;
		dialog.default_filter = pdf_filter;
		dialog.open.begin (this, null, (obj, res) => {
			try {
				this.load_file (dialog.open.end (res));
			} catch (Error e) {
				/* dialog dismissed */
			}
		});
	}

	public void load_file (File file) {
		Poppler.Document doc;
		try {
			doc = new Poppler.Document.from_file (file.get_uri (), null);
		} catch (Error e) {
			this.show_toast (e.message);
			return;
		}

		this.pdf_file = file;
		this.document = doc;

		this.window_title.title = file.get_basename ();
		var parent = file.get_parent ();
		this.window_title.subtitle = parent != null ? parent.get_path () : "";

		for (var i = 0; i < METADATA_PROPERTIES.length; i++) {
			string? value;
			doc.get (METADATA_PROPERTIES[i], out value);
			this.metadata_rows[i].text = value ?? "";
		}

		this.format_value.label = doc.get_pdf_version_string ();
		this.pages_value.label = doc.get_n_pages ().to_string ();

		this.creation_row.set_datetime (doc.creation_datetime ?? new DateTime.now_local ());
		this.mod_row.set_datetime (doc.mod_datetime ?? new DateTime.now_local ());

		this.metadata_group.sensitive = true;
		this.dates_group.sensitive = true;
		this.view_row.sensitive = true;
		this.tag_action.set_enabled (true);
	}

	private void view_document () {
		var pdf_list = new List<File> ();
		pdf_list.append (this.pdf_file);
		try {
			this.viewer.launch (pdf_list, null);
		} catch (Error e) {
			this.show_toast (e.message);
		}
	}

	private void write_information () {
		for (var i = 0; i < METADATA_PROPERTIES.length; i++) {
			this.document.set (METADATA_PROPERTIES[i], this.metadata_rows[i].text);
		}
		this.document.creation_datetime = this.creation_row.date;
		this.document.mod_datetime = this.mod_row.date;

		try {
			var tmp_path = Path.build_filename (this.pdf_file.get_parent ().get_path (), ".pdftag-XXXXXX.pdf");
			var fd = FileUtils.mkstemp (tmp_path);
			if (fd == -1) {
				throw new IOError.FAILED ("Could not create a temporary file");
			}
			FileUtils.close (fd);
			var tmp_file = File.new_for_path (tmp_path);
			this.document.save (tmp_file.get_uri ());
			try {
				/* preserve the permissions of the original file; copy_attributes
				 * is not used because it fails on standard::size */
				var info = this.pdf_file.query_info (FileAttribute.UNIX_MODE, FileQueryInfoFlags.NONE);
				tmp_file.set_attribute_uint32 (FileAttribute.UNIX_MODE, info.get_attribute_uint32 (FileAttribute.UNIX_MODE), FileQueryInfoFlags.NONE);
			} catch (Error e) {
				warning (e.message);
			}
			tmp_file.move (this.pdf_file, FileCopyFlags.OVERWRITE);
			this.show_toast ("Tagged “%s”".printf (this.pdf_file.get_basename ()));
		} catch (Error e) {
			this.show_toast (e.message);
		}
	}
}

public class Pdftag.Application : Adw.Application {
	public Application () {
		Object (application_id: "com.github.arrufat.pdftag",
			flags: ApplicationFlags.HANDLES_OPEN);
	}

	protected override void startup () {
		base.startup ();
		var quit_action = new SimpleAction ("quit", null);
		quit_action.activate.connect (() => this.quit ());
		this.add_action (quit_action);
		this.set_accels_for_action ("app.quit", { "<Control>q" });
		this.set_accels_for_action ("win.open", { "<Control>o" });
		this.set_accels_for_action ("win.tag", { "<Control>s" });

		/* hide the edit (pencil) icons of the entry rows */
		var css = new Gtk.CssProvider ();
		css.load_from_string ("row.entry .edit-icon { opacity: 0; -gtk-icon-size: 1px; min-width: 0; margin: 0; padding: 0; }");
		add_style_provider_for_display (Gdk.Display.get_default (), css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
	}

	private Window get_window () {
		return this.active_window as Window ?? new Window (this);
	}

	protected override void activate () {
		this.get_window ().present ();
	}

	protected override void open (File[] files, string hint) {
		var win = this.get_window ();
		win.load_file (files[0]);
		win.present ();
	}
}

int main (string[] args) {
	return new Pdftag.Application ().run (args);
}
