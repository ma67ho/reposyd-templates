/* reposyd-reportblock-header */
/* eslint-disable no-useless-constructor */
const { ReportFramework } = require('@reposyd/core')
/* reposyd-reportblock-header */

class ReportBlockNotes extends ReportFramework.ReportBlock {
  constructor (section, engine) {
    super(section, engine)
    /* reposyd-reportblock-constructor */
    /* reposyd-reportblock-constructor */
  }
  /* reposyd-reportblock-body */

  renderContent () {
    const query = {
      filter: {
        tags: {
        }
      }
    }
    query.filter.tags[this.section.reportblock.options.reportblock.tags.match] = this.section.reportblock.options.reportblock.tags.tags
    const notes = this.designData.notes.find(query)
    notes.sort((a, b) => {
      const ret = a.number.localeCompare(b.number, this.language.substr(0, 2))
      if (ret !== 0) {
        return ret
      }
      return a.title.localeCompare(b.title, this.language.substr(0, 2))
    })
    for (const note of notes) {
      this.writeHtml(note.number + ' ' + note.title, 'title')
      this.writeHtml(note.description, 'description')
    }
  }

  /* reposyd-reportblock-body */
  static DefaultSettings () {
    return {
      reportblock: [{
        id: 'tags',
        title: {
          'de-DE': 'Schlagwörter',
          'en-US': 'Tags'
        },
        type: 'select.tag',
        tags: {
          selection: 'multiple'
        },
        value: {
          match: 'atleastone',
          tags: []
        }
      },
      {
        id: 'printtags',
        title: {
          'de-DE': 'Schlagwörter drucken',
          'en-US': 'Print tags'
        },
        type: 'boolean',
        value: false
      }
      ],
      section: [
        {
          id: 'pageBreak',
          title: {
            'de-DE': 'Seitenumbruch',
            'en-US': 'Page Break'
          },
          type: 'boolean',
          value: false
        }
      ]
    }
    /* reposyd-reportblock-settings */
  }
}

module.exports = ReportBlockNotes
