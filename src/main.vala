// modules: gtk+-3.0 poppler-glib
using GLib;
using Gtk;

public class Pdftag : ApplicationWindow {
	private string filename;
	private Poppler.Document document;
	private Button button;
	private Entry title_entry;
	private Entry author_entry;
	private Entry subject_entry;
	private Entry keywords_entry;
	private Entry creation_entry;
	private Entry mod_entry;
	private HeaderBar header;
	private CheckButton check;
	private string document_path;
	private bool overwrite = false;

	private Button creation_date_btn;
	private SpinButton creation_hour_btn;
	private SpinButton creation_min_btn;
	private SpinButton creation_sec_btn;

	private Button mod_date_btn;
	private SpinButton mod_hour_btn;
	private SpinButton mod_min_btn;
	private SpinButton mod_sec_btn;

	public Pdftag () {

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
		open_button.clicked.connect (on_open_clicked);
		header.add (open_button);

		var grid = new Grid ();

		title_entry = new Entry ();
		title_entry.set_placeholder_text ("Title");
		title_entry.set_icon_from_icon_name (EntryIconPosition.SECONDARY, "edit-clear-symbolic");
		title_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				title_entry.set_text ("");
			}
		});

		author_entry = new Entry ();
		author_entry.set_placeholder_text ("Author");
		author_entry.set_icon_from_icon_name (EntryIconPosition.SECONDARY, "edit-clear-symbolic");
		author_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				author_entry.set_text ("");
			}
		});

		subject_entry = new Entry ();
		subject_entry.set_placeholder_text ("Subject");
		subject_entry.set_icon_from_icon_name (EntryIconPosition.SECONDARY, "edit-clear-symbolic");
		subject_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				subject_entry.set_text ("");
			}
		});

		keywords_entry = new Entry ();
		keywords_entry.set_placeholder_text ("Keywords");
		keywords_entry.set_icon_from_icon_name (EntryIconPosition.SECONDARY, "edit-clear-symbolic");
		keywords_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				keywords_entry.set_text ("");
			}
		});

		creation_entry = new Entry ();
		creation_entry.set_placeholder_text ("YYYY-MM-DDThh:mm:ss");
		creation_entry.set_icon_from_icon_name (EntryIconPosition.SECONDARY, "edit-clear-symbolic");
		creation_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				creation_entry.set_text ("");
			}
		});

		mod_entry = new Entry ();
		mod_entry.set_placeholder_text ("YYYY-MM-DDThh:mm:ss");
		mod_entry.set_icon_from_icon_name (EntryIconPosition.SECONDARY, "edit-clear-symbolic");
		mod_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				mod_entry.set_text ("");
			}
		});

		button = new Gtk.Button.with_label ("Tag");
		button.clicked.connect (on_tag);

		var title_label = new Label ("<b>Title</b>");
		title_label.set_use_markup (true);
		grid.attach (title_label, 0, 0, 1, 1);
		grid.attach (title_entry, 1, 0, 5, 1);

		var author_label = new Label ("<b>Author</b>");
		author_label.set_use_markup (true);
		grid.attach (author_label, 0, 1, 1, 1);
		grid.attach (author_entry, 1, 1, 5, 1);

		var subject_label = new Label ("<b>Subject</b>");
		subject_label.set_use_markup (true);
		grid.attach (subject_label, 0, 2, 1, 1);
		grid.attach (subject_entry, 1, 2, 5, 1);

		var keywords_label = new Label ("<b>Keywords</b>");
		keywords_label.set_use_markup (true);
		grid.attach (keywords_label, 0, 3, 1, 1);
		grid.attach (keywords_entry, 1, 3, 5, 1);

		var creation_label = new Label ("<b>Created</b>");
		creation_label.set_use_markup (true);
		grid.attach (creation_label, 0, 4, 1, 1);

		this.creation_date_btn = new Button.with_label ("YYYY-MM-DD");
		grid.attach (this.creation_date_btn, 1, 4, 2, 1);
		this.creation_date_btn.clicked.connect (on_date_clicked);

		this.creation_hour_btn = new SpinButton.with_range (0, 23, 1);
		this.creation_hour_btn.set_tooltip_text ("hours");
		grid.attach (creation_hour_btn, 3, 4, 1, 1);
		this.creation_min_btn = new SpinButton.with_range (0, 59, 1);
		this.creation_min_btn.set_tooltip_text ("minutes");
		grid.attach (creation_min_btn, 4, 4, 1, 1);
		this.creation_sec_btn = new SpinButton.with_range (0, 59, 1);
		this.creation_sec_btn.set_tooltip_text ("seconds");
		grid.attach (creation_sec_btn, 5, 4, 1, 1);

		var mod_label = new Label ("<b>Modified</b>");
		mod_label.set_use_markup (true);
		grid.attach (mod_label, 0, 5, 1, 1);

		this.mod_date_btn = new Button.with_label ("YYYY-MM-DD");
		grid.attach (mod_date_btn, 1, 5, 2, 1);
		mod_date_btn.clicked.connect (on_date_clicked);

		this.mod_hour_btn = new SpinButton.with_range (0, 23, 1);
		this.mod_hour_btn.set_tooltip_text ("hours");
		grid.attach (mod_hour_btn, 3, 5, 1, 1);
		this.mod_min_btn = new SpinButton.with_range (0, 59, 1);
		this.mod_min_btn.set_tooltip_text ("minutes");
		grid.attach (mod_min_btn, 4, 5, 1, 1);
		this.mod_sec_btn = new SpinButton.with_range (0, 59, 1);
		this.mod_sec_btn.set_tooltip_text ("seconds");
		grid.attach (mod_sec_btn, 5, 5, 1, 1);

		check = new CheckButton.with_label ("Overwrite");
		grid.attach (check, 1, 6, 1, 1);

		grid.attach (button, 5, 6, 1, 1);

		grid.set_column_spacing (10);
		grid.set_row_spacing (10);
		grid.set_column_homogeneous (true);

		check.toggled.connect (on_toggled);

		this.add (grid);
	}

	private void on_date_clicked (Button btn) {
		var popover = new Popover (btn);
		var calendar = new Calendar ();
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
			this.filename = file_chooser.get_filename ();
			this.header.title = Path.get_basename (filename);
			this.header.subtitle = filename.replace (Path.get_basename (filename), "");
		}
		file_chooser.destroy ();
		/* update text entries with current metadata */
		try {
			/* var date_format = "%Y-%m-%dT%H:%M:%S"; */
			var date_format = "%Y-%m-%d";
			this.document_path = "file://" + filename;
			this.document = new Poppler.Document.from_file (this.document_path, null);
			this.title_entry.text = this.document.title ?? "";
			this.author_entry.text = this.document.author ?? "";
			this.subject_entry.text = this.document.subject ?? "";
			this.keywords_entry.text = this.document.keywords ?? "";

			var creation_date = new DateTime.from_unix_local ((int64) this.document.creation_date);
			this.creation_date_btn.label = creation_date.format (date_format);
			this.creation_hour_btn.text = creation_date.format ("%H");
			this.creation_min_btn.text = creation_date.format ("%M");
			this.creation_sec_btn.text = creation_date.format ("%S");

			var mod_date = new DateTime.from_unix_local ((int64) this.document.mod_date);
			this.mod_date_btn.label = mod_date.format (date_format);
			this.mod_hour_btn.text = mod_date.format ("%H");
			this.mod_min_btn.text = mod_date.format ("%M");
			this.mod_sec_btn.text = mod_date.format ("%S");
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

	private void on_tag () {
			if (this.document_path != null) {
				this.document.title = this.title_entry.text;
				this.document.author = this.author_entry.text;
				this.document.subject = this.subject_entry.text;
				this.document.keywords = this.keywords_entry.text;

				// date parsing
				var creation_date_raw = this.creation_date_btn.label.split ("-", 3);
				var creation_date = new DateTime.local (
					int.parse(creation_date_raw[0]), // year
					int.parse(creation_date_raw[1]), // month
					int.parse(creation_date_raw[2]), // day
					this.creation_hour_btn.get_value_as_int (),
					this.creation_min_btn.get_value_as_int (),
					this.creation_min_btn.get_value ()
					);
				var mod_date_raw = this.mod_date_btn.label.split ("-", 3);
				var mod_date = new DateTime.local (
					int.parse(mod_date_raw[0]), // year
					int.parse(mod_date_raw[1]), // month
					int.parse(mod_date_raw[2]), // day
					this.mod_hour_btn.get_value_as_int (),
					this.mod_min_btn.get_value_as_int (),
					this.mod_min_btn.get_value ()
					);
				this.document.creation_date = (int) creation_date.to_unix ();
				this.document.mod_date = (int) mod_date.to_unix ();

				// save the modified document
				try {
					FileIOStream iostream;
					var tmp_pdf = File.new_tmp ("tmp-XXXXXX.pdf", out iostream);
					this.document.save("file://" + tmp_pdf.get_path ());
					if (overwrite) {
						var final_pdf = File.new_for_commandline_arg (this.document_path);
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

	var pdftag = new Pdftag ();
	pdftag.show_all ();

	Gtk.main ();
	return 0;
}
