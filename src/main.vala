// modules: gtk+-3.0 poppler-glib
using GLib;
using Gtk;

public class Pdftag : ApplicationWindow {
	private File pdf_file;
	private Poppler.Document document;
	private Entry title_entry;
	private Entry author_entry;
	private Entry subject_entry;
	private Entry keywords_entry;
	private Entry producer_entry;
	private Entry creator_entry;
	private Label format_label;
	private Label pages_label;
	private HeaderBar header;
	private CheckButton check;
	private bool overwrite = false;

	private Button creation_date_btn;
	private SpinButton creation_hour_btn;
	private SpinButton creation_min_btn;
	private SpinButton creation_sec_btn;

	private Button mod_date_btn;
	private SpinButton mod_hour_btn;
	private SpinButton mod_min_btn;
	private SpinButton mod_sec_btn;

	private Button creation_now_btn;
	private Button mod_now_btn;
	private DateTime creation_date = new DateTime.now_local ();
	private DateTime mod_date = new DateTime.now_local ();
	private string date_format = "%Y-%m-%d";

	private Button tag_btn;

	public Pdftag (ref unowned string[] args) {

		header = new HeaderBar ();
		header.title = "pdftag";
		header.subtitle = "Add or modify metadata";
		header.set_show_close_button (true);

		this.set_titlebar (header);
		this.destroy.connect (Gtk.main_quit);
		this.resizable = false;
		this.border_width = 10;
		this.window_position = Gtk.WindowPosition.CENTER;

		var open_button = new Button.from_icon_name ("document-open-symbolic", IconSize.SMALL_TOOLBAR);
		open_button.set_tooltip_text ("Select a PDF");
		open_button.clicked.connect (on_open_clicked);
		header.add (open_button);

		/* grid configuration */
		var grid = new Grid ();
		grid.set_column_spacing (10);
		grid.set_row_spacing (10);
		grid.set_column_homogeneous (true);
		var row = 0;

		/* title */
		title_entry = new Entry ();
		title_entry.set_placeholder_text ("Title");
		title_entry.set_icon_from_icon_name (EntryIconPosition.SECONDARY, "edit-clear-symbolic");
		title_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				title_entry.set_text ("");
			}
		});
		var title_label = new Label ("<b>Title</b>");
		title_label.set_use_markup (true);
		grid.attach (title_label, 0, row, 1, 1);
		grid.attach (title_entry, 1, row, 5, 1);
		row++;

		/* author */
		author_entry = new Entry ();
		author_entry.set_placeholder_text ("Author");
		author_entry.set_icon_from_icon_name (EntryIconPosition.SECONDARY, "edit-clear-symbolic");
		author_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				author_entry.set_text ("");
			}
		});
		var author_label = new Label ("<b>Author</b>");
		author_label.set_use_markup (true);
		grid.attach (author_label, 0, row, 1, 1);
		grid.attach (author_entry, 1, row, 5, 1);
		row++;

		/* subject */
		subject_entry = new Entry ();
		subject_entry.set_placeholder_text ("Subject");
		subject_entry.set_icon_from_icon_name (EntryIconPosition.SECONDARY, "edit-clear-symbolic");
		subject_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				subject_entry.set_text ("");
			}
		});
		var subject_label = new Label ("<b>Subject</b>");
		subject_label.set_use_markup (true);
		grid.attach (subject_label, 0, row, 1, 1);
		grid.attach (subject_entry, 1, row, 5, 1);
		row++;

		/* keywords */
		keywords_entry = new Entry ();
		keywords_entry.set_placeholder_text ("Keywords");
		keywords_entry.set_icon_from_icon_name (EntryIconPosition.SECONDARY, "edit-clear-symbolic");
		keywords_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				keywords_entry.set_text ("");
			}
		});
		var keywords_label = new Label ("<b>Keywords</b>");
		keywords_label.set_use_markup (true);
		grid.attach (keywords_label, 0, row, 1, 1);
		grid.attach (keywords_entry, 1, row, 5, 1);
		row++;

		/* producer */
		producer_entry = new Entry ();
		producer_entry.set_placeholder_text ("Producer");
		producer_entry.set_icon_from_icon_name (EntryIconPosition.SECONDARY, "edit-clear-symbolic");
		producer_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				producer_entry.set_text ("");
			}
		});
		var producer_label = new Label ("<b>Producer</b>");
		producer_label.set_use_markup (true);
		grid.attach (producer_label, 0, row, 1, 1);
		grid.attach (producer_entry, 1, row, 5, 1);
		row++;

		/* creator */
		creator_entry = new Entry ();
		creator_entry.set_placeholder_text ("Creator");
		creator_entry.set_icon_from_icon_name (EntryIconPosition.SECONDARY, "edit-clear-symbolic");
		creator_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				creator_entry.set_text ("");
			}
		});
		var creator_label = new Label ("<b>Creator</b>");
		creator_label.set_use_markup (true);
		grid.attach (creator_label, 0, row, 1, 1);
		grid.attach (creator_entry, 1, row, 5, 1);
		row++;

		/* creation date */
		var creation_label = new Label ("<b>Created</b>");
		creation_label.set_use_markup (true);
		grid.attach (creation_label, 0, row, 1, 1);
		this.creation_date_btn = new Button.with_label (creation_date.format (this.date_format));
		grid.attach (this.creation_date_btn, 1, row, 1, 1);
		this.creation_date_btn.clicked.connect (on_date_clicked);
		this.creation_hour_btn = new SpinButton.with_range (0, 23, 1);
		this.creation_hour_btn.set_tooltip_text ("hours");
		grid.attach (creation_hour_btn, 2, row, 1, 1);
		this.creation_min_btn = new SpinButton.with_range (0, 59, 1);
		this.creation_min_btn.set_tooltip_text ("minutes");
		grid.attach (creation_min_btn, 3, row, 1, 1);
		this.creation_sec_btn = new SpinButton.with_range (0, 59, 1);
		this.creation_sec_btn.set_tooltip_text ("seconds");
		grid.attach (creation_sec_btn, 4, row, 1, 1);
		this.creation_now_btn = new Button.with_label ("Now");
		grid.attach (this.creation_now_btn, 5, row, 1, 1);
		this.creation_now_btn.clicked.connect (on_creation_now_clicked);

		this.creation_hour_btn.set_value (double.parse (creation_date.format ("%H")));
		this.creation_min_btn.set_value (double.parse (creation_date.format ("%M")));
		this.creation_sec_btn.set_value (double.parse (creation_date.format ("%S")));
		row++;

		/* modification date */
		var mod_label = new Label ("<b>Modified</b>");
		mod_label.set_use_markup (true);
		grid.attach (mod_label, 0, row, 1, 1);
		this.mod_date_btn = new Button.with_label (mod_date.format (this.date_format));
		grid.attach (mod_date_btn, 1, row, 1, 1);
		mod_date_btn.clicked.connect (on_date_clicked);
		this.mod_hour_btn = new SpinButton.with_range (0, 23, 1);
		this.mod_hour_btn.set_tooltip_text ("hours");
		grid.attach (mod_hour_btn, 2, row, 1, 1);
		this.mod_min_btn = new SpinButton.with_range (0, 59, 1);
		this.mod_min_btn.set_tooltip_text ("minutes");
		grid.attach (mod_min_btn, 3, row, 1, 1);
		this.mod_sec_btn = new SpinButton.with_range (0, 59, 1);
		this.mod_sec_btn.set_tooltip_text ("seconds");
		grid.attach (mod_sec_btn, 4, row, 1, 1);
		this.mod_now_btn = new Button.with_label ("Now");
		grid.attach (this.mod_now_btn, 5, row, 1, 1);
		this.mod_now_btn.clicked.connect (on_mod_now_clicked);

		this.mod_hour_btn.set_value (double.parse (mod_date.format ("%H")));
		this.mod_min_btn.set_value (double.parse (mod_date.format ("%M")));
		this.mod_sec_btn.set_value (double.parse (mod_date.format ("%S")));
		row++;

		/* information */
		var info_label = new Label ("<b>Information</b>");
		info_label.set_use_markup (true);
		grid.attach (info_label, 0, row, 1, 1);

		this.format_label = new Label ("Format: N/A");
		grid.attach (this.format_label, 1, row, 1, 1);

		this.pages_label = new Label ("Pages: N/A");
		grid.attach (this.pages_label, 2, row, 1, 1);
		row++;

		/* overwrite checkbox */
		this.check = new CheckButton.with_label ("Overwrite");
		check.toggled.connect (on_toggled);
		grid.attach (this.check, 1, row, 1, 1);

		/* tag button */
		this.tag_btn = new Gtk.Button.with_label ("Tag");
		this.tag_btn.clicked.connect (write_information);
		grid.attach (tag_btn, 5, row, 1, 1);
		row++;

		this.add (grid);

		this.add_accels ();

		/* handle first argument -- it only works as an absolute path */
		if (args[1] != null) {
			this.pdf_file = File.new_for_path (args[1]);
			read_information ();
		}

	}

	[Signal (action = true)]
	private signal void open_file_dialog ();

	[Signal (action = true)]
	private signal void quit_app ();

	private void add_accels () {
		var accel_group = new AccelGroup ();
		this.add_accel_group (accel_group);
		this.open_file_dialog.connect (on_open_clicked);
		this.quit_app.connect (Gtk.main_quit);
		this.add_accelerator ("open_file_dialog", accel_group, Gdk.keyval_from_name ("o"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE);
		this.add_accelerator ("quit_app", accel_group, Gdk.keyval_from_name ("q"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE);
	}

	private void on_creation_now_clicked () {
		this.creation_date = new DateTime.now_local ();
		this.creation_date_btn.label = creation_date.format (this.date_format);
		this.creation_hour_btn.set_value (double.parse (creation_date.format ("%H")));
		this.creation_min_btn.set_value (double.parse (creation_date.format ("%M")));
		this.creation_sec_btn.set_value (double.parse (creation_date.format ("%S")));
	}

	private void on_mod_now_clicked () {
		this.mod_date = new DateTime.now_local ();
		this.mod_date_btn.label = mod_date.format (this.date_format);
		this.mod_hour_btn.set_value (double.parse (mod_date.format ("%H")));
		this.mod_min_btn.set_value (double.parse (mod_date.format ("%M")));
		this.mod_sec_btn.set_value (double.parse (mod_date.format ("%S")));
	}

	private void on_date_clicked (Button btn) {
		var popover = new Popover (btn);
		var calendar = new Calendar ();
		var date_parse = btn.label.split ("-", 3);
		calendar.select_month (int.parse (date_parse[1]) - 1, int.parse (date_parse[0]));
		calendar.select_day (int.parse (date_parse[2]));
		popover.add (calendar);
		calendar.day_selected.connect (() => {
			var date = "%04d-%02d-%02d".printf (calendar.year, calendar.month + 1, calendar.day);
			btn.label = date;
		});
		popover.show_all ();
	}

	private void on_open_clicked () {
		var file_chooser = new FileChooserDialog (
			"Open file", this, FileChooserAction.OPEN, "_Cancel", ResponseType.CANCEL, "_Open", ResponseType.ACCEPT);
		var filter = new FileFilter ();
		file_chooser.set_filter (filter);
		filter.add_mime_type ("image/pdf");
		if (file_chooser.run () == ResponseType.ACCEPT) {
			this.pdf_file = file_chooser.get_file ();
		}
		file_chooser.destroy ();

		/* update text entries with current metadata */
		if (this.pdf_file != null) {
			read_information ();
		}
	}

	private void read_information () {
		try {
			var base_name = Path.get_basename (pdf_file.get_path ());
			this.header.title = base_name;
			this.header.subtitle = this.pdf_file.get_path ().replace (base_name, "");
			this.document = new Poppler.Document.from_file (this.pdf_file.get_uri (), null);
			this.title_entry.text = this.document.title ?? "";
			this.author_entry.text = this.document.author ?? "";
			this.subject_entry.text = this.document.subject ?? "";
			this.keywords_entry.text = this.document.keywords ?? "";
			this.producer_entry.text = this.document.producer ?? "";
			this.creator_entry.text = this.document.creator ?? "";
			this.format_label.label = "Format: " + this.document.get_pdf_version_string ();
			this.pages_label.label = "Pages: " + this.document.get_n_pages ().to_string ();

			this.creation_date = new DateTime.from_unix_local ((int64) this.document.creation_date);
			this.creation_date_btn.label = creation_date.format (this.date_format);
			this.creation_hour_btn.set_value (double.parse (creation_date.format ("%H")));
			this.creation_min_btn.set_value (double.parse (creation_date.format ("%M")));
			this.creation_sec_btn.set_value (double.parse (creation_date.format ("%S")));

			this.mod_date = new DateTime.from_unix_local ((int64) this.document.mod_date);
			this.mod_date_btn.label = mod_date.format (this.date_format);
			this.mod_hour_btn.set_value (double.parse (mod_date.format ("%H")));
			this.mod_min_btn.set_value (double.parse (mod_date.format ("%M")));
			this.mod_sec_btn.set_value (double.parse (mod_date.format ("%S")));
		} catch (Error e) {
			print ("%s\n", e.message);
		}
	}

	private void on_toggled () {
		if (this.check.active) {
			overwrite = true;
			message ("Output will be overwritten");
		} else {
			overwrite = false;
			message ("Original file will be kept");
		}
	}

	private void write_information () {
			if (this.pdf_file != null) {
				this.document.title = this.title_entry.text;
				this.document.author = this.author_entry.text;
				this.document.subject = this.subject_entry.text;
				this.document.keywords = this.keywords_entry.text;
				this.document.producer = this.producer_entry.text;
				this.document.creator = this.creator_entry.text;

				// date parsing
				var creation_date_raw = this.creation_date_btn.label.split ("-", 3);
				this.creation_date = new DateTime.local (
					int.parse(creation_date_raw[0]), // year
					int.parse(creation_date_raw[1]), // month
					int.parse(creation_date_raw[2]), // day
					this.creation_hour_btn.get_value_as_int (),
					this.creation_min_btn.get_value_as_int (),
					this.creation_sec_btn.get_value ()
					);
				var mod_date_raw = this.mod_date_btn.label.split ("-", 3);
				this.mod_date = new DateTime.local (
					int.parse(mod_date_raw[0]), // year
					int.parse(mod_date_raw[1]), // month
					int.parse(mod_date_raw[2]), // day
					this.mod_hour_btn.get_value_as_int (),
					this.mod_min_btn.get_value_as_int (),
					this.mod_sec_btn.get_value ()
					);
				this.document.creation_date = (int) creation_date.to_unix ();
				this.document.mod_date = (int) mod_date.to_unix ();

				// save the modified document
				try {
					FileIOStream iostream;
					var tmp_pdf = File.new_tmp ("pdftag-tmp-XXXXXX.pdf", out iostream);
					this.document.save(tmp_pdf.get_uri ());
					if (overwrite) {
						var final_pdf = File.new_for_commandline_arg (this.pdf_file.get_path ());
						tmp_pdf.move (final_pdf, FileCopyFlags.OVERWRITE, null, null);
					}
				} catch (Error e) {
					print ("%s\n", e.message);
				}
			} else {
				message ("No document was selected!");
			}
	}

	private static void remove_dir_recursively (string path) {
		string content;
		try {
			var directory = Dir.open (path);
			while ((content = directory.read_name ()) != null) {
				var content_path = path + Path.DIR_SEPARATOR_S + content;
				if (FileUtils.test (content_path + Path.DIR_SEPARATOR_S + content, FileTest.IS_DIR)) {
					remove_dir_recursively (content_path);
					FileUtils.remove (content_path);
				} else {
					FileUtils.remove (content_path);
				}
			}
			FileUtils.remove (path);
		} catch (FileError e) {
			error ("%s\n", e.message);
		}
	}

}

int main (string[] args) {
	Gtk.init (ref args);

	var pdftag = new Pdftag (ref args);
	pdftag.show_all ();

	Gtk.main ();
	return 0;
}
