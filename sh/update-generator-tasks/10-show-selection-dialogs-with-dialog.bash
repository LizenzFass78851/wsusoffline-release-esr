# This file will be sourced by the shell bash.
#
# Filename: 10-show-selection-dialogs-with-dialog.bash
#
# Copyright (C) 2018-2022 Hartmut Buhrmester
#                         <wsusoffline-scripts-xxyh@hartmut-buhrmester.de>
#
# License
#
#     This file is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published
#     by the Free Software Foundation, either version 3 of the License,
#     or (at your option) any later version.
#
#     This file is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#     General Public License for more details.
#
#     You should have received a copy of the GNU General
#     Public License along with this program.  If not, see
#     <http://www.gnu.org/licenses/>.
#
# Description
#
#     This file uses the external command "dialog" to display nicely
#     formatted dialogs for the updates, languages and optional
#     downloads. All three dialogs allow multiple selections. This
#     allows to combine all needed downloads in just one call of the
#     download script.
#
#     If dialog is not installed, then this script will simply return and
#     the next file will be sourced. That file uses the internal command
#     "select" of the bash as a fallback.
#
#     The state of the three selection dialogs will be saved between
#     runs. On the first run, default values will be provided. After
#     displaying the dialogs, the current settings are saved to the file
#     update-generator.ini. On the next run, the last used settings will
#     be loaded again.
#
# Compatibility
#
#     The approach to provide default values for the dialogs, and to save
#     and restore the settings uses indexed and associative arrays. The
#     compatibility of this approach was tested on:
#
#     Debian GNU/Linux 6.0.10 (squeeze), bash version 4.1.5(1)-release
#     Debian GNU/Linux 8.11 (jessie), bash version 4.3.30(1)-release
#     Debian GNU/Linux 9.6 (stretch), bash version 4.4.12(1)-release

# ========== Configuration ================================================

settings_file="update-generator.ini"

# Define an indexed array of the keys only
#
# This list could also be extracted from the associative array below,
# but then the keys would be listed in a seemingly random order. For
# example, try:
#
#   declare -p all_values
#   printf '%s\n' "${!all_values[@]}"
#
# To write the settings file in a recognizable order, the list of all
# keys must be created manually.


# Separating the keys simplifies the generation of the selection dialogs
update_keys=(
    w60 w60-x64 w61 w61-x64
    w62-x64 w63 w63-x64 w100 w100-x64
    o2k13 o2k13-x64 o2k16 o2k16-x64
    all all-x86 all-x64 all-win all-win-x86 all-win-x64 all-ofc
    all-ofc-x86
)

language_keys=(
    deu enu ara chs cht csy dan nld fin fra ell heb hun ita jpn kor nor
    plk ptg ptb rus esn sve trk
)

option_keys=(
    sp cpp dotnet wddefs
    msse wddefs8
)

# Combining the keys to a single list simplifies the handling of the
# settings file
all_keys=(
    "${update_keys[@]}"
    "${language_keys[@]}"
    "${option_keys[@]}"
)

declare -A all_labels=(
    [w60]="Windows Server 2008, 32-bit"
    [w60-x64]="Windows Server 2008, 64-bit"
    [w61]="Windows 7, 32-bit"
    [w61-x64]="Windows 7 / Server 2008 R2, 64-bit"
    [w62-x64]="Windows Server 2012, 64-bit             (deprecated)"
    [w63]="Windows 8.1, 32-bit                     (deprecated)"
    [w63-x64]="Windows 8.1 / Server 2012 R2, 64-bit    (deprecated)"
    [w100]="Windows 10, 32-bit                      (deprecated)"
    [w100-x64]="Windows 10 / Server 2016/2019, 64-bit   (deprecated)"
    [o2k13]="Office 2013, 32-bit                     (deprecated)"
    [o2k13-x64]="Office 2013, 32-bit and 64-bit          (deprecated)"
    [o2k16]="Office 2016, 32-bit                     (deprecated)"
    [o2k16-x64]="Office 2016, 32-bit and 64-bit          (deprecated)"
    [all]="All Windows and Office updt, 32/64-bit  (deprecated)"
    [all-x86]="All Windows and Office updates, 32-bit  (deprecated)"
    [all-x64]="All Windows and Office updates, 64-bit  (deprecated)"
    [all-win]="All Windows updates, 32-bit and 64-bit  (deprecated)"
    [all-win-x86]="All Windows updates, 32-bit             (deprecated)"
    [all-win-x64]="All Windows updates, 64-bit             (deprecated)"
    [all-ofc]="All Office updates, 32-bit and 64-bit   (deprecated)"
    [all-ofc-x86]="All Office updates, 32-bit              (deprecated)"
    [deu]="German"
    [enu]="English"
    [ara]="Arabic"
    [chs]="Chinese (Simplified)"
    [cht]="Chinese (Traditional)"
    [csy]="Czech"
    [dan]="Danish"
    [nld]="Dutch"
    [fin]="Finnish"
    [fra]="French"
    [ell]="Greek"
    [heb]="Hebrew"
    [hun]="Hungarian"
    [ita]="Italian"
    [jpn]="Japanese"
    [kor]="Korean"
    [nor]="Norwegian"
    [plk]="Polish"
    [ptg]="Portuguese"
    [ptb]="Portuguese (Brazil)"
    [rus]="Russian"
    [esn]="Spanish"
    [sve]="Swedish"
    [trk]="Turkish"
    [sp]="Service Packs"
    [cpp]="Visual C++ Runtime Libraries"
    [dotnet]=".NET Frameworks"
    [wddefs]="Windows Defender updates for Windows Vista and 7"
    [msse]="Microsoft Security Essentials"
    [wddefs8]="Windows Defender updates for Windows 8, 8.1 and 10"
)


# The associative array "all_values" is used to hold all values throughout
# the script. The meaning of the values changes three times:
#
# - The array is set to the DEFAULT values at this point.
# - The LAST USED settings are read from an ini file, if existing.
# - After displaying the selections dialogs with the utility "dialog",
#   the values are updated to the CURRENT settings.
# - The current settings are finally written back to the ini file.

declare -A all_values=(
    [w60]="off"
    [w60-x64]="off"
    [w61]="on"
    [w61-x64]="on"
    [w62-x64]="off"
    [w63]="off"
    [w63-x64]="off"
    [w100]="off"
    [w100-x64]="off"
    [o2k13]="off"
    [o2k13-x64]="off"
    [o2k16]="off"
    [o2k16-x64]="off"
    [all]="off"
    [all-x86]="off"
    [all-x64]="off"
    [all-win]="off"
    [all-win-x86]="off"
    [all-win-x64]="off"
    [all-ofc]="off"
    [all-ofc-x86]="off"
    [deu]="on"
    [enu]="on"
    [ara]="off"
    [chs]="off"
    [cht]="off"
    [csy]="off"
    [dan]="off"
    [nld]="off"
    [fin]="off"
    [fra]="off"
    [ell]="off"
    [heb]="off"
    [hun]="off"
    [ita]="off"
    [jpn]="off"
    [kor]="off"
    [nor]="off"
    [plk]="off"
    [ptg]="off"
    [ptb]="off"
    [rus]="off"
    [esn]="off"
    [sve]="off"
    [trk]="off"
    [sp]="on"
    [cpp]="off"
    [dotnet]="off"
    [wddefs]="off"
    [msse]="off"
    [wddefs8]="off"
)


download_parameters=()


# ========== Functions ====================================================

# Read the last used settings from the settings file. If this file does
# not exist yet, the default values will be kept.

function read_previous_settings ()
{
    local key=""
    local value=""

    log_info_message "Reading last used settings..."

    # General settings for updates, languages and included downloads
    for key in "${all_keys[@]}"
    do
        # Get the last used value from the settings file. If the file
        # does not exist yet, or if the key was not found, then the
        # array all_values will not be changed, and the default value,
        # as defined above, will be kept.
        if value="$(read_setting "${settings_file}" "${key}")"
        then
            # Update the setting to the last used value
            all_values["${key}"]="${value}"
        fi
    done

    log_info_message "Read last used settings."
    echo ""

    return 0
}

# After displaying the selection dialogs, write the current settings
# back to the settings file. The file will created at this step, if it
# does not exist yet.

function write_current_settings ()
{
    local key=""
    local value=""

    log_info_message "Writing current settings..."

    # General settings for updates, languages and included downloads
    for key in "${all_keys[@]}"
    do
        value="${all_values[${key}]}"
        write_setting "${settings_file}" "${key}" "${value}"
    done

    log_info_message "Wrote current settings."
    echo ""

    return 0
}

# The function check_dialog_result_code tests the result code of dialog
#
#   0 = OK-Button
#   1 = Cancel-Button
# 255 = Escape-Key

function check_dialog_result_code ()
{
    case $? in
        0)
            #echo "OK button pressed"
            :
        ;;
        1)
            echo "Cancel button pressed"
            exit 1
        ;;
        255)
            echo "Escape key pressed"
            exit 255
        ;;
        *)
            echo "Unknown result code"
            exit 1
        ;;
    esac
    return 0
}


function show_selection_dialogs_with_dialog ()
{
    local key=""
    local -a updates_dialog=()
    local -a languages_dialog=()
    local -a options_dialog=()
    local update_list=""
    local update_list_csv=""
    local language_list=""
    local language_list_csv=""
    local option_list=""
    local next_option=""
    local confirmation=""

    # The selection dialogs must be defined locally to have the values
    # evaluated at runtime.
    for key in "${update_keys[@]}"
    do
        updates_dialog+=( "${key}"
                          "${all_labels[${key}]}"
                          "${all_values[${key}]}" )
    done

    for key in "${language_keys[@]}"
    do
        languages_dialog+=( "${key}"
                            "${all_labels[${key}]}"
                            "${all_values[${key}]}" )
    done

    for key in "${option_keys[@]}"
    do
        options_dialog+=( "${key}"
                          "${all_labels[${key}]}"
                          "${all_values[${key}]}" )
    done

    # Update selection: On the first run, there are no updates
    # preselected. The selection dialog must be repeated, until a
    # non-empty list of updates is returned.
    while [[ -z "${update_list}" ]]
    do
        # If the shell option errexit or a trap on ERR is used, then
        # the result code of each command must be directly checked. This
        # usually means, that it must be inserted in an if-then-else-fi
        # construct.
        #
        # For some reason, the negation with "!" does not seem to work
        # in this case.
        if update_list="$( dialog                      \
            --title "Update selection"                 \
            --stdout                                   \
            --checklist "Please select your updates:"  \
                         0 0 0                         \
                        "${updates_dialog[@]}"         \
            )"
        then
            :
        else
            check_dialog_result_code
        fi
    done

    # Language selection: On the first run, the default languages German
    # and English will be selected. These languages may be deselected,
    # but at least one language must be returned.
    while [[ -z "${language_list}" ]]
    do
        if language_list="$( dialog                      \
            --title "Language selection"                 \
            --stdout                                     \
            --checklist "Please select your languages:"  \
                         0 0 0                           \
                        "${languages_dialog[@]}"         \
            )"
        then
            :
        else
            check_dialog_result_code
        fi
    done

    # Optional downloads: Service packs are selected on the first run,
    # but they can be unchecked. The list of optional downloads may be
    # empty, if none is selected.
    if option_list="$( dialog                                  \
        --title "Optional downloads"                           \
        --stdout                                               \
        --checklist "Please select the downloads to include:"  \
                     0 0 0                                     \
                    "${options_dialog[@]}"                     \
        )"
    then
        :
    else
        check_dialog_result_code
    fi

    # Remove any quotation marks, which old versions of dialog may insert
    update_list="${update_list//\"/}"
    language_list="${language_list//\"/}"
    option_list="${option_list//\"/}"

    # Change word lists to comma-separated lists
    update_list_csv="${update_list// /,}"
    language_list_csv="${language_list// /,}"

    # Assemble command line parameters for the download script
    download_parameters=( "${update_list_csv}" "${language_list_csv}" )

    if [[ -n "${option_list}" ]]
    then
        for next_option in ${option_list}
        do
            download_parameters+=( "-include${next_option}" )
        done
    fi

    # Print summary and confirm download command
    confirmation="Your selections are:\\n
\\n
* Updates: ${update_list}\\n
* Languages: ${language_list}\\n
* Included downloads: ${option_list}\\n
\\n
The command to download the updates is:\\n
\\n
./download-updates.bash ${download_parameters[*]}\\n
\\n
Do you wish to run it now?"

    if dialog --title "Summary" --yesno "${confirmation}" 0 0
    then
        :
    else
        check_dialog_result_code
    fi

    # Add one empty line after the last dialog, otherwise the next
    # message would overlap with the bottom of the dialog.
    echo ""

    # Update the associative array "all_values" to the results from the
    # selection dialogs
    #
    # Set all values to "off"
    for key in "${all_keys[@]}"
    do
        all_values["${key}"]="off"
    done

    # Change the values of the selected keys to "on"
    for key in ${update_list} ${language_list} ${option_list}
    do
        all_values["${key}"]="on"
    done

    return 0
}


function run_download_script ()
{
    local -i result_code="0"

    log_info_message "Running: ./download-updates.bash ${download_parameters[*]}"
    echo ""

    if ./download-updates.bash "${download_parameters[@]}"
    then
        log_info_message "Download script returned with success"
        # TODO: Add any post-processing here, e.g. call the copy-to-target
        # script or create ISO images of the client directory.
    else
        result_code="$?"
        log_warning_message "Download script returned with error code ${result_code}"
    fi

    return 0
}

# ========== Commands =====================================================

# If the external command "dialog" is installed, then it will be used
# to create the selection dialogs for updates, languages and optional
# downloads. The function run_download_script will call the download
# script. Afterwards, the script update-generator.bash will exit.
#
# If "dialog" is NOT installed, then this script will simply return,
# and the next script in the directory update-generator-tasks will be
# sourced. This will use the internal command "select" of the bash as
# a fallback.

if type -P dialog >/dev/null
then
    read_previous_settings
    show_selection_dialogs_with_dialog
    write_current_settings
    run_download_script
    exit 0
else
    log_warning_message "Please install the package dialog, to display nicely formatted dialogs in the terminal window."
fi

return 0
