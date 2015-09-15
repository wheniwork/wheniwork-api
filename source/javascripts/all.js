//= require './jquery_ui'
//= require_tree .

function toggleCodeSection(selector) {
    $(selector).toggleClass('expanded');
}

function toggleTable(selector) {
    if ($(selector).hasClass('expanded')) {
        collapseTable(selector);
    } else {
        expandTable(selector);
    }
}

function collapseTable(selector) {
    function processRow(sip, ns) {
        var sectionInProgress = sip;
        var needsSpacer = ns;

        return function(i, tr) {
            var rowCanCollapse = $(tr).hasClass("collapse");
            if (rowCanCollapse) {
                sectionInProgress = true;
                needsSpacer = !needsSpacer;
            } else if (sectionInProgress) {
                sectionInProgress = false;
                if (needsSpacer) {
                    $(tr).before($('<tr class="spacer"></tr>'));
                }
                needsSpacer = false;
            }
        }
    }

    var table = $(selector).eq(0);

    if (! $(table).hasClass('expanded')) {
        return;
    }

    var sectionInProgress = false;
    var needsSpacer = false;
    $(table).find('tr').each(processRow(sectionInProgress, needsSpacer));

    $(table).removeClass('expanded');
}

function expandTable(selector) {
    var table = $(selector).eq(0);

    if ($(table).hasClass('expanded')) {
        return;
    }

    $(table).find('tr.spacer').remove();

    $(table).addClass('expanded');
}

$(document).ready(function() {
    $('.collapse-links a').on('click', function(event) {
        event.preventDefault();
        var linkTarget = $(this).attr("href");
        
        var scrollTo = $(linkTarget).offset().top - 40;
        if ($(document).scrollTop() > scrollTo) {
            $("html, body").scrollTop($(linkTarget).offset().top - 40);
        }
    });
});
